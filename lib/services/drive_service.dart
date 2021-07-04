import 'dart:async';
import 'dart:io' as io;
import 'dart:developer' as developer;

import 'package:every_calendar/http/google_auth_client.dart';
import 'package:every_calendar/services/login_service.dart';
import 'package:googleapis/drive/v3.dart';

class DriveService {
  static final DriveService _instance = DriveService._internal();
  final LoginService _loginService = LoginService();
  GoogleAuthClient? _googleAuthClient;
  DriveApi? _driveApi;

  static const String _tenantFilePath =
      "https://drive.google.com/u/3/uc?id=1-clx4365I-z3Nq-jFmNQHKkMh_hWyLXd&export=download";

  Future<DriveApi> getDriveApi() async {
    if (_googleAuthClient == null) {
      var headers = await _loginService.loggedUser.authHeaders;
      _googleAuthClient = GoogleAuthClient(headers);
    }
    _driveApi ??= DriveApi(_googleAuthClient!);
    return _driveApi!;
  }

  DriveService._internal();

  factory DriveService() {
    return _instance;
  }

  Future<void> syncTenants(io.File file) async {
    final Completer<void> completer = Completer<void>.sync();
    io.HttpClient httpClient = io.HttpClient();

    try {
      var request = await httpClient.getUrl(Uri.parse(_tenantFilePath));
      var response = await request.close();

      if (response.statusCode == 200) {
        var counter = 0;
        response.listen(
          (List<int> chunk) {
            file.writeAsBytesSync(
              chunk,
              mode: counter == 0 ? io.FileMode.write : io.FileMode.append,
            );
            counter++;
          },
          onDone: () {
            completer.complete();
          },
          onError: (e) => completer.completeError(e),
        );
      } else {
        developer.log('Error code: ' + response.statusCode.toString());
        completer.complete();
      }
    } catch (ex, stackTrace) {
      developer.log('Can not fetch url');
      completer.completeError(ex, stackTrace);
    }

    return completer.future;
  }
}
