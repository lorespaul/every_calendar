import 'dart:async';

import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/core/db/database_manager.dart';
import 'package:every_calendar/core/google/drive_manager.dart';
import 'package:every_calendar/core/google/login_service.dart';
import 'package:every_calendar/core/shared/shared_constants.dart';
import 'package:every_calendar/utils/date_time_ultils.dart';
import 'package:googleapis/drive/v3.dart';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'package:synchronized/synchronized.dart';

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  SyncManager._internal();

  final DatabaseManager _databaseManager = DatabaseManager();
  final DriveManager _driveManager = DriveManager();
  final LoginService _loginService = LoginService();
  String? tenantFolder;
  List<AbstractEntity>? collections;

  final Lock _lock = Lock();

  factory SyncManager() {
    _instance._databaseManager.onChange ??= _instance.synchronizeOne;
    return _instance;
  }

  Future<void> synchronize() async {
    if (_lock.locked) {
      return;
    }
    await _lock.synchronized(() async {
      try {
        var nextLastRefresh =
            DateTimeUtils.nowUtc().subtract(const Duration(hours: 1));
        File remoteTenantFolder =
            await _driveManager.getRemoteTenantFolder(tenantFolder!);

        for (var collection in collections!) {
          var collectionName = collection.getTableName();
          var lastRefresh = await _getLastResfresh(collection);
          var remoteFolder = await _driveManager.getOrCreateDriveFolder(
            collectionName,
            parentId: remoteTenantFolder.id!,
          );

          var remoteFiles = await _driveManager.getRemoteFilesInFolder(
            remoteFolder.id!,
            fromModifiedDate: lastRefresh,
          );
          List<int> synchronizedIds = await _syncRemoteToLocal(
            remoteFiles,
            collection,
          );

          var localData = (await _databaseManager.getAllNotInId(
                collectionName,
                synchronizedIds,
                fromModifiedDate: lastRefresh,
              )) ??
              [];

          if (localData.isNotEmpty) {
            await _syncLocalToRemote(remoteFolder.id!, localData, collection);
          }
          await _setLastResfresh(collection, nextLastRefresh);
        }
      } catch (e) {
        developer.log(e.toString());
      }
    });
  }

  Future<void> synchronizeOne(AbstractEntity collection, String uuid) async {
    await _lock.synchronized(() async {
      File remoteTenantFolder =
          await _driveManager.getRemoteTenantFolder(tenantFolder!);

      var collectionName = collection.getTableName();
      var remoteFolder = await _driveManager.getOrCreateDriveFolder(
        collectionName,
        parentId: remoteTenantFolder.id!,
      );

      var remoteFiles = await _driveManager.getRemoteFileInFolder(
        '$uuid${SharedConstants.jsonExtension}',
        remoteFolder.id!,
      );
      List<int> synchronizedIds = await _syncRemoteToLocal(
        remoteFiles,
        collection,
      );

      if (synchronizedIds.isEmpty) {
        var localData = await _databaseManager.getByUuid(
          collectionName,
          uuid,
        );

        if (localData != null) {
          await _syncLocalToRemote(remoteFolder.id!, [localData], collection);
        }
      }
    });
  }

  Future<void> _syncLocalToRemote(
    String parentId,
    List<Map<String, dynamic>> localData,
    AbstractEntity collection,
  ) async {
    var localEntities = localData.map((e) => collection.fromMap(e)).toList();
    var names = localEntities
        .map((e) => '${e.getUuid()}${SharedConstants.jsonExtension}')
        .toList();
    var files = await _driveManager.getRemoteFilesInFolder(
      parentId,
      names: names,
    );
    for (var localEntity in localEntities) {
      // create remote file
      var localEntityName =
          '${localEntity.getUuid()}${SharedConstants.jsonExtension}';
      var found = files.firstWhereOrNull((e) => e.name == localEntityName);
      if (localEntity.getModifiedBy() == _loginService.loggedUser.email &&
          localEntity.getDeletedAt() == null) {
        if (found == null) {
          // create remote file only if is modified by me
          await _driveManager.createFile(
            localEntity.toMap(),
            localEntity.getUuid(),
            parentId,
          );
        } else {
          await _driveManager.updateFile(
            localEntity.toMap(),
            localEntity.getUuid(),
            found.id!,
          );
        }
      } else {
        // else delete local data
        await _databaseManager.deleteByUuid(
          collection.getTableName(),
          localEntity.getUuid(),
        );
      }
    }
  }

  Future<List<int>> _syncRemoteToLocal(
    List<File> remoteFiles,
    AbstractEntity collection,
  ) async {
    var collectionName = collection.getTableName();
    List<int> synchronizedIds = [];
    for (var rf in remoteFiles) {
      if (rf.trashed == true) {
        // delete local data
        await _databaseManager.deleteByUuid(
          collectionName,
          rf.name!.replaceAll(SharedConstants.jsonExtension, ''),
        );
        continue;
      }

      var ld = await _databaseManager.getByUuid(
        collectionName,
        rf.name!.replaceAll(SharedConstants.jsonExtension, ''),
      );

      if (ld == null) {
        // insert to db
        var remoteEntity = await _remoteFileToAbstractEntity(rf, collection);
        if (remoteEntity != null) {
          var inserted = await _databaseManager.insert(
            collectionName,
            remoteEntity,
            uuid: remoteEntity.getUuid(),
            isSynchronizer: true,
          );
          if (inserted != null) {
            synchronizedIds.add(inserted['id']);
          }
        }
      } else {
        var localEntity = collection.fromMap(ld);
        if (localEntity.getDeletedAt() != null) {
          // trash remote file and local data
          await _driveManager.trashFile(rf.id!);
          await _databaseManager.deleteByUuid(
            collectionName,
            localEntity.getUuid(),
          );
        } else if (localEntity.getModifiedAt().isAfter(rf.modifiedTime!)) {
          // update remote file
          await _driveManager.updateFile(
            localEntity.toMap(),
            localEntity.getUuid(),
            rf.id!,
          );
          synchronizedIds.add(ld['id']);
        } else if (localEntity.getModifiedAt().isBefore(rf.modifiedTime!)) {
          // && !rf.modifiedByMe!) {
          // update local data
          var remoteEntity = await _remoteFileToAbstractEntity(rf, collection);
          if (remoteEntity != null &&
              localEntity.getModifiedByDevice() !=
                  remoteEntity.getModifiedByDevice()) {
            await _databaseManager.update(
              collectionName,
              remoteEntity.getUuid(),
              remoteEntity,
              isSynchronizer: true,
            );
            synchronizedIds.add(ld['id']);
          }
        } else {
          // do nothing
          synchronizedIds.add(ld['id']);
        }
      }
    }
    return synchronizedIds;
  }

  Future<AbstractEntity?> _remoteFileToAbstractEntity(
    File rf,
    AbstractEntity collection,
  ) async {
    var entity = await _driveManager.downloadFile(rf.id!);
    if (entity != null) {
      return collection.fromMap(entity);
    }
    return null;
  }

  Future<DateTime?> _getLastResfresh(AbstractEntity collection) async {
    var lastRefreshKey = _getRefreshKey(collection.getTableName());
    var prefs = await SharedPreferences.getInstance();
    var timestamp = prefs.getInt(lastRefreshKey);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  Future<void> _setLastResfresh(
    AbstractEntity collection,
    DateTime refreshDate,
  ) async {
    var lastRefreshKey = _getRefreshKey(collection.getTableName());
    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt(lastRefreshKey, refreshDate.millisecondsSinceEpoch);
  }

  String _getRefreshKey(String collection) {
    return '${_loginService.loggedUser.id}-$collection-$tenantFolder';
  }
}
