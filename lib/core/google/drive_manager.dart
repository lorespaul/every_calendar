import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:developer' as developer;

import 'package:every_calendar/core/db/database_setup.dart';
import 'package:every_calendar/core/google/config.dart';
import 'package:every_calendar/core/google/login_service.dart';
import 'package:every_calendar/core/shared/shared_constants.dart';
import 'package:every_calendar/http/google_auth_client.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriveManager {
  static final DriveManager _instance = DriveManager._internal();
  DriveManager._internal();

  static const String _mimeTypeFolder = 'application/vnd.google-apps.folder';
  static const String _baseFolder = 'every_calendar';
  static const String _jsonMediaType = 'application/json';

  final LoginService _loginService = LoginService();
  GoogleAuthClient? _googleAuthClient;
  DriveApi? _driveApi;

  static const String _tenantFileUrl =
      "https://drive.google.com/u/3/uc?id=1-clx4365I-z3Nq-jFmNQHKkMh_hWyLXd&export=download";

  Future<DriveApi> getDriveApi() async {
    if (_googleAuthClient == null) {
      var headers = await _loginService.loggedUser.authHeaders;
      _googleAuthClient = GoogleAuthClient(headers);
    }
    _driveApi ??= DriveApi(_googleAuthClient!);
    return _driveApi!;
  }

  factory DriveManager() {
    return _instance;
  }

  Future<Config?> getConfig() async {
    var prefs = await SharedPreferences.getInstance();
    try {
      io.HttpClient httpClient = io.HttpClient();
      var request = await httpClient.getUrl(Uri.parse(_tenantFileUrl));
      var response = await request.close();

      if (response.statusCode == 200) {
        final Completer<void> completer = Completer<void>.sync();

        List<int> bytes = [];
        response.listen(
          (List<int> chunk) => bytes.addAll(chunk),
          onDone: () => completer.complete(),
          onError: (e) => completer.completeError(e),
        );

        await completer.future;
        String json = utf8.decode(bytes);
        await prefs.setString(SharedConstants.config, json);
        return configFromJson(json);
      } else {
        developer.log('Error code: ' + response.statusCode.toString());
      }
    } catch (ex) {
      developer.log('Can not fetch url');
    }
    var config = prefs.getString(SharedConstants.config);
    if (config != null && config.isNotEmpty) {
      return configFromJson(config);
    }
    return null;
  }

  Future<Map<String, dynamic>?> downloadFile(String fileId) async {
    var driveApi = await getDriveApi();
    Media response = await driveApi.files.get(
      fileId,
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
      return jsonDecode(json);
    } catch (e) {
      return null;
    }
  }

  Future<File> createFile(
    Map<String, dynamic> entity,
    String uuid,
    String parentId,
  ) async {
    var driveApi = await getDriveApi();
    File fileMetadata = File()
      ..name = '$uuid${SharedConstants.jsonExtension}'
      ..parents = [parentId]
      ..mimeType = _jsonMediaType;
    var bytes = utf8.encode(jsonEncode(entity));
    Media media = Media(_getStream(bytes), bytes.length);
    return await driveApi.files.create(fileMetadata, uploadMedia: media);
  }

  Future<File> updateFile(
    Map<String, dynamic> entity,
    String uuid,
    String fileId,
  ) async {
    var driveApi = await getDriveApi();
    File fileMetadata = File()
      ..name = '$uuid${SharedConstants.jsonExtension}'
      ..mimeType = _jsonMediaType;
    var bytes = utf8.encode(jsonEncode(entity));
    Media media = Media(_getStream(bytes), bytes.length);
    return await driveApi.files.update(
      fileMetadata,
      fileId,
      uploadMedia: media,
    );
  }

  Future<File> trashFile(String fileId) async {
    var driveApi = await getDriveApi();
    File fileMetadata = File()..trashed = true;
    return await driveApi.files.update(fileMetadata, fileId);
  }

  Future<void> grantPermission(String email) async {
    var driveApi = await getDriveApi();
    File folder = await getRemoteTenantFolder(DatabaseSetup.getContext());
    var request = Permission()
      ..type = 'user'
      ..role = 'writer'
      ..emailAddress = email;
    await driveApi.permissions.create(request, folder.id!);
  }

  Future<File> getRemoteTenantFolder(String context) async {
    File remoteBaseFolder = await getOrCreateDriveFolder(_baseFolder);
    return await getOrCreateDriveFolder(
      context,
      parentId: remoteBaseFolder.id!,
    );
  }

  Stream<List<int>> _getStream(List<int> bytes) async* {
    yield bytes;
  }

  Future<File> getOrCreateDriveFolder(
    String name, {
    String parentId = '',
  }) async {
    var driveApi = await getDriveApi();
    FileList folder = await driveApi.files.list(
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
      result = await driveApi.files.create(fileMetadata);
    }

    return result;
  }

  Future<List<File>> getRemoteFilesInFolder(String parentId) async {
    var driveApi = await getDriveApi();
    FileList folder = await driveApi.files.list(
      q: "mimeType != '$_mimeTypeFolder' and '$parentId' in parents",
      $fields: "files(id, name, modifiedTime, modifiedByMe, trashed)",
    );
    if (folder.files != null) {
      return folder.files!;
    }
    return List.empty();
  }

  Future<List<File>> getRemoteFileInFolder(String name, String parentId) async {
    var driveApi = await getDriveApi();
    FileList folder = await driveApi.files.list(
      q: "mimeType != '$_mimeTypeFolder' and '$parentId' in parents and name = '$name'",
      $fields: "files(id, name, modifiedTime, modifiedByMe, trashed)",
    );
    if (folder.files != null) {
      return folder.files!;
    }
    return List.empty();
  }
}
