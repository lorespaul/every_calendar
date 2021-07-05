import 'dart:async';

import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/core/db/database_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'dart:convert';
import 'dart:developer' as developer;

class SyncManager {
  static const String _jsonExtension = '.json';
  static const String _jsonMediaType = 'application/json';
  static const _mimeTypeFolder = 'application/vnd.google-apps.folder';
  static const _baseFolder = 'every_calendar';
  final String _tenantFolder;
  final List<AbstractEntity> _collections;
  final DatabaseManager _databaseManager = DatabaseManager();
  final DriveApi _driveApi;
  final GoogleSignInAccount _loggedUser;

  SyncManager.build(
    String tenantFolder,
    List<AbstractEntity> collections,
    DriveApi driveApi,
    GoogleSignInAccount loggedUser,
  )   : _tenantFolder = tenantFolder,
        _collections = collections,
        _driveApi = driveApi,
        _loggedUser = loggedUser;

  Future<void> synchronizeWithDrive() async {
    try {
      File remoteBaseFolder = await getOrCreateDriveFolder(_baseFolder);
      File remoteTenantFolder = await getOrCreateDriveFolder(
        _tenantFolder,
        parentId: remoteBaseFolder.id!,
      );

      for (var collection in _collections) {
        var collectionName = collection.getTableName();
        var remoteFolder = await getOrCreateDriveFolder(
          collectionName,
          parentId: remoteTenantFolder.id!,
        );

        var remoteFiles = await getRemoteFilesInFolder(remoteFolder.id!);
        List<int> synchronizedIds = await syncRemoteToLocal(
          remoteFiles,
          collection,
        );

        var localData = (await _databaseManager.getAllNotInId(
              collectionName,
              synchronizedIds,
            )) ??
            [];

        await syncLocalToRemote(remoteFolder.id!, localData, collection);
      }
    } catch (e) {
      developer.log(e.toString());
    }
  }

  Future<void> syncLocalToRemote(
    String parentId,
    List<Map<String, dynamic>> localData,
    AbstractEntity collection,
  ) async {
    for (var ld in localData) {
      // create remote file
      var localEntity = collection.fromMap(ld);
      if (localEntity.getModifiedBy() == _loggedUser.email &&
          localEntity.getDeletedAt() == null) {
        // create remote file only if is modified by me
        File fileMetadata = File()
          ..name = '${localEntity.getUuid()}$_jsonExtension'
          ..parents = [parentId]
          ..mimeType = _jsonMediaType;
        var bytes = utf8.encode(jsonEncode(localEntity.toMap()));
        Media media = Media(getStream(bytes), bytes.length);
        await _driveApi.files.create(fileMetadata, uploadMedia: media);
      } else {
        // else delete local data
        await _databaseManager.deleteByUuid(
          collection.getTableName(),
          localEntity.getUuid(),
        );
      }
    }
  }

  Future<List<int>> syncRemoteToLocal(
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
          rf.name!.replaceAll(_jsonExtension, ''),
        );
        continue;
      }

      var ld = await _databaseManager.getByUuid(
        collectionName,
        rf.name!.replaceAll(_jsonExtension, ''),
      );

      if (ld == null) {
        // insert to db
        var remoteEntity = await remoteFileToAbstractEntity(rf, collection);
        if (remoteEntity != null) {
          var inserted = await _databaseManager.insert(
            collectionName,
            remoteEntity,
            setBreadcrumbs: false,
          );
          if (inserted != null) {
            synchronizedIds.add(inserted['id']);
          }
        }
      } else {
        var localEntity = collection.fromMap(ld);
        if (localEntity.getDeletedAt() != null) {
          // trash remote file and local data
          File fileMetadata = File()..trashed = true;
          await _driveApi.files.update(fileMetadata, rf.id!);
          await _databaseManager.deleteByUuid(
            collectionName,
            localEntity.getUuid(),
          );
        } else if (localEntity.getModifiedAt().isAfter(rf.modifiedTime!)) {
          // update remote file
          File fileMetadata = File()
            ..name = '${localEntity.getUuid()}$_jsonExtension'
            ..mimeType = _jsonMediaType;
          var bytes = utf8.encode(jsonEncode(localEntity.toMap()));
          Media media = Media(getStream(bytes), bytes.length);
          _driveApi.files.update(
            fileMetadata,
            rf.id!,
            uploadMedia: media,
          );
          synchronizedIds.add(ld['id']);
        } else if (localEntity.getModifiedAt().isBefore(rf.modifiedTime!) &&
            !rf.modifiedByMe!) {
          // update local data
          var remoteEntity = await remoteFileToAbstractEntity(rf, collection);
          if (remoteEntity != null) {
            await _databaseManager.update(
              collectionName,
              remoteEntity.getUuid(),
              remoteEntity,
              setBreadcrumbs: false,
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

  Stream<List<int>> getStream(List<int> bytes) async* {
    yield bytes;
  }

  Future<AbstractEntity?> remoteFileToAbstractEntity(
    File rf,
    AbstractEntity collection,
  ) async {
    Media response = await _driveApi.files.get(
      rf.id!,
      downloadOptions: DownloadOptions.fullMedia,
    ) as Media;
    List<int> bytes = [];
    final Completer<void> completer = Completer<void>.sync();
    response.stream.listen(
      (List<int> chunk) => bytes.addAll(chunk),
      onDone: () => completer.complete(),
      onError: (e) => completer.completeError(e),
    );
    try {
      await completer.future;
      String json = utf8.decode(bytes);
      return collection.fromMap(jsonDecode(json));
    } catch (e) {
      return null;
    }
  }

  Future<File> getOrCreateDriveFolder(
    String name, {
    String parentId = '',
  }) async {
    FileList folder = await _driveApi.files.list(
      q: "mimeType = '$_mimeTypeFolder' and name = '$name' and trashed = false",
    );
    File result;
    if (folder.files != null && folder.files!.isNotEmpty) {
      result = folder.files!.first;
    } else {
      File fileMetadata = File()
        ..name = name
        ..mimeType = _mimeTypeFolder;
      if (parentId.isNotEmpty) {
        fileMetadata.parents = [parentId];
      }
      result = await _driveApi.files.create(fileMetadata);
    }

    return result;
  }

  Future<List<File>> getRemoteFilesInFolder(String parentId) async {
    FileList folder = await _driveApi.files.list(
      q: "mimeType != '$_mimeTypeFolder' and '$parentId' in parents",
      $fields: "files(id, name, modifiedTime, modifiedByMe, trashed)",
    );
    if (folder.files != null) {
      return folder.files!;
    }
    return List.empty();
  }
}
