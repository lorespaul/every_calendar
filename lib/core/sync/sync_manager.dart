import 'package:collection/collection.dart';
import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/core/db/database_manager.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'dart:developer' as developer;

class SyncManager {
  static const _mimeTypeFolder = 'application/vnd.google-apps.folder';
  static const _baseFolder = 'every_calendar';
  final String _tenantFolder;
  final List<AbstractEntity> _collections;
  final DatabaseManager _databaseManager = DatabaseManager();
  DriveApi? _driveApi;

  SyncManager.build(String tenantFolder, List<AbstractEntity> collections)
      : _tenantFolder = tenantFolder,
        _collections = collections;

  set driveApi(DriveApi driveApi) {
    _driveApi = driveApi;
  }

  Future<void> synchronizeWithDrive() async {
    var baseLocalPath = await getApplicationDocumentsDirectory();
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
        var localData = await _databaseManager.getAll(collectionName);

        List<String> filesReady = [];
        for (var rf in remoteFiles) {
          // var lf = localFiles.firstWhereOrNull((e) =>
          //     e.path.contains(rf.name!) ||
          //     e.path.contains(rf.name! + Constants.fileDeleteExtension));
          // if (lf == null || lf.statSync().modified.isBefore(rf.modifiedTime!)) {
          //   // create or update file local
          //   Media response = await _driveApi!.files.get(rf.id!,
          //       downloadOptions: DownloadOptions.fullMedia) as Media;
          //   response.stream.listen((event) {});
          //   filesReady.add(lf!.path);
          // } else if (lf.path.endsWith(Constants.fileDeleteExtension)) {
          //   // delete file remote and local
          //   await _driveApi!.files.delete(rf.id!);
          //   filesReady.add(lf.path);
          // }
        }
        // for (var lf in localFiles) {
        //   if (!filesReady.contains(lf.path)) {}
        //   // var stat = lf.statSync();
        //   // stat.
        // }
      }
    } catch (e) {
      developer.log(e.toString());
    }
  }

  Future<File> getOrCreateDriveFolder(
    String name, {
    String parentId = '',
  }) async {
    FileList folder = await _driveApi!.files.list(
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
      result = await _driveApi!.files.create(fileMetadata);
    }

    return result;
  }

  Future<List<File>> getRemoteFilesInFolder(String parentId) async {
    FileList folder = await _driveApi!.files.list(
      q: "mimeType != '$_mimeTypeFolder' and '$parentId' in parents",
    );
    if (folder.files != null) {
      return folder.files!;
    }
    return List.empty();
  }
}
