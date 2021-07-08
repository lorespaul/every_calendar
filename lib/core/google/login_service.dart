import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:googleapis/calendar/v3.dart';
import 'dart:developer' as developer;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';

import 'package:googleapis/drive/v2.dart';

class LoginService {
  static const String webClientId =
      '343383817775-sppv52k52ce4e7eq46fkcmk0edn499fr.apps.googleusercontent.com';
  static const String desktopClientId =
      '343383817775-sppv52k52ce4e7eq46fkcmk0edn499fr.apps.googleusercontent.com';

  static final LoginService _instance = LoginService._internal();

  GoogleSignIn? _googleSignIn;
  GoogleSignInAccount? _currentUser;
  Function()? onLoggedIn;

  GoogleSignInAccount get loggedUser => _currentUser!;

  factory LoginService() {
    return _instance;
  }

  LoginService._internal() {
    _googleSignIn ??= _initGoogleSignIn();
    _googleSignIn!.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _currentUser = account;
      onLoggedIn?.call();
    });
  }

  GoogleSignIn _initGoogleSignIn() {
    String? clientId;
    if (kIsWeb) {
      clientId =
          '343383817775-sppv52k52ce4e7eq46fkcmk0edn499fr.apps.googleusercontent.com';
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      clientId =
          '343383817775-jjseikjhc3k1tp534kj5udi04gn871ak.apps.googleusercontent.com';
    }
    return GoogleSignIn(
      scopes: <String>[
        CalendarApi.calendarScope,
        DriveApi.driveScope,
      ],
      clientId: clientId,
    );
  }

  Future<GoogleSignInAccount?> silentlyLogin() async {
    return await _googleSignIn!.signInSilently();
  }

  Future<GoogleSignInAccount?> login() async {
    if (_currentUser != null) {
      return _currentUser;
    }
    try {
      return await _googleSignIn!.signIn();
    } catch (error) {
      developer.log(error.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _googleSignIn!.disconnect();
      // ignore: empty_catches
    } catch (e) {}
    _currentUser = null;
  }

  bool isLoggedIn() {
    return _currentUser != null;
  }
}
