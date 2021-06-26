import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';

import 'dart:developer' as developer;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GoogleSignIn? _googleSignIn;

  GoogleSignInAccount? _currentUser;
  // String _contactText = '';

  void initPlatform() {
    String? clientId;
    if (kIsWeb) {
      clientId =
          '343383817775-sppv52k52ce4e7eq46fkcmk0edn499fr.apps.googleusercontent.com';
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      clientId =
          '343383817775-jjseikjhc3k1tp534kj5udi04gn871ak.apps.googleusercontent.com';
    }
    _googleSignIn = GoogleSignIn(
      scopes: <String>[CalendarApi.calendarScope],
      clientId: clientId,
    );
  }

  @override
  void initState() {
    super.initState();
    initPlatform();
    _googleSignIn!.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        developer.log("logged in!");
        // _handleGetContact(_currentUser!);
      }
    });
    _googleSignIn!.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: user,
            ),
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email),
          ),
          const Text("Signed in successfully."),
          const Text(""),
          ElevatedButton(
            child: const Text('SIGN OUT'),
            onPressed: _handleSignOut,
          ),
          // ElevatedButton(
          //   child: const Text('REFRESH'),
          //   onPressed: () => _handleGetContact(user),
          // ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text("You are not currently signed in."),
          ElevatedButton(
            child: const Text('SIGN IN'),
            onPressed: _handleSignIn,
          ),
        ],
      );
    }
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn!.signIn();
    } catch (error) {
      developer.log(error.toString());
    }
  }

  Future<void> _handleSignOut() => _googleSignIn!.disconnect();
}
