import 'package:every_calendar/core/google/login_service.dart';
import 'package:http/http.dart' as http;

import 'dart:developer' as developer;

class GoogleAuthClient extends http.BaseClient {
  Map<String, String> _headers;

  final http.Client _client = http.Client();
  final LoginService _loginService;

  GoogleAuthClient(this._loginService, this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      return _client.send(request..headers.addAll(_headers));
    } catch (e) {
      developer.log('Error on google auth, retry...');
      var user = await _loginService.silentlyLogin();
      _headers = await user!.authHeaders;
      return _client.send(request..headers.addAll(_headers));
    }
  }
}
