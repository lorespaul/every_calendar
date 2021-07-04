import 'package:googleapis/drive/v3.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'dart:developer' as developer;

class SyncManager {
  static const _mimeTypeFolder = 'application/vnd.google-apps.folder';
  static const _baseFolder = 'every_calendar';
  final String _folder;
  DriveApi? _driveApi;

  SyncManager.build(String folder) : _folder = folder;

  set driveApi(DriveApi driveApi) {
    _driveApi = driveApi;
  }

  Future<void> synchronizeWithDrive() async {
    var baseLocalPath = await getApplicationDocumentsDirectory();
    try {
      File remoteBaseFolder = await getOrCreateDriveFolder(_baseFolder);
      File remoteTenantFolder = await getOrCreateDriveFolder(
        _folder,
        parentId: remoteBaseFolder.id!,
      );

      // var localTenantFolder = getOrCreateLocalFolder('$baseLocalPath/$_folder');
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

  // io.Directory getOrCreateLocalFolder(String folderPath) {
  //   var folder = io.Directory(folderPath);
  //   if (!folder.existsSync()) {
  //     folder.createSync(recursive: true);
  //   }
  //   folder.
  //   return folder;
  // }
}
