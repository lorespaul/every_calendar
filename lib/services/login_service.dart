import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:googleapis/calendar/v3.dart';
import 'dart:developer' as developer;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';

import 'package:googleapis/drive/v2.dart';

class LoginService {
  static final LoginService _instance = LoginService._internal();

  static const String webClientId =
      '343383817775-sppv52k52ce4e7eq46fkcmk0edn499fr.apps.googleusercontent.com';
  static const String desktopClientId =
      '343383817775-sppv52k52ce4e7eq46fkcmk0edn499fr.apps.googleusercontent.com';

  GoogleSignIn? _googleSignIn;
  GoogleSignInAccount? _currentUser;
  Function()? _onLoggedIn;

  GoogleSignInAccount get loggedUser => _currentUser!;

  factory LoginService({Function()? onLoggedIn}) {
    _instance._onLoggedIn = onLoggedIn;
    return _instance;
  }

  LoginService._internal() {
    _googleSignIn ??= _initGoogleSignIn();
    _googleSignIn!.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _currentUser = account;
      _onLoggedIn?.call();
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
    await _googleSignIn!.signInSilently();
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
    await _googleSignIn!.disconnect();
    _currentUser = null;
  }

  bool isLoggedIn() {
    return _currentUser != null;
  }
}