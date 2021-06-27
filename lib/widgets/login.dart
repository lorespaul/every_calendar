import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({Key? key, required this.title, required this.onLogin})
      : super(key: key);

  final String title;
  final Function() onLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // const Text("You are not currently signed in."),
            ElevatedButton(
              child: const Text('SIGN IN'),
              onPressed: onLogin,
            ),
          ],
        ),
      ),
    );
  }
}
