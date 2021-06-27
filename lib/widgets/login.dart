import 'package:every_calendar/widgets/scaffold_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({
    Key? key,
    required this.title,
    required this.onLogin,
  }) : super(key: key);

  final String title;
  final Function() onLogin;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      title: title,
      builder: () {
        return ElevatedButton(
          child: const Text('SIGN IN'),
          onPressed: onLogin,
        );
      },
    );
  }
}
