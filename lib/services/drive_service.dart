import 'dart:io';

import 'package:every_calendar/http/google_auth_client.dart';
import 'package:every_calendar/services/login_service.dart';
import 'package:googleapis/drive/v3.dart';

class DriveService {
  static final DriveService _instance = DriveService._internal();
  final LoginService _loginService = LoginService();
  GoogleAuthClient? _googleAuthClient;
  DriveApi? _driveApi;

  static const String _tenantFilePath =
      "https://drive.google.com/file/d/1-clx4365I-z3Nq-jFmNQHKkMh_hWyLXd/view";

  Future<DriveApi> _getDriveApi() async {
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

  Future<void> getTenants() async {
    HttpClient httpClient = HttpClient();
    File file;
    String filePath = '';
    String myUrl = '';

    try {
      // myUrl = url+'/'+fileName;
      // var request = await httpClient.getUrl(Uri.parse(myUrl));
      // var response = await request.close();
      // if(response.statusCode == 200) {
      //   var bytes = await consolidateHttpClientResponseBytes(response);
      //   filePath = '$dir/$fileName';
      //   file = File(filePath);
      //   await file.writeAsBytes(bytes);
      // }
      // else
      //   filePath = 'Error code: '+response.statusCode.toString();
    } catch (ex) {
      filePath = 'Can not fetch url';
    }

    // return filePath;
  }
}
