import 'package:every_calendar/services/loader_service.dart';
import 'package:every_calendar/services/login_service.dart';
import 'package:every_calendar/widgets/login.dart';
import 'package:every_calendar/widgets/main_tabs.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Every Calendar'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LoginService _loginService = LoginService();
  final LoaderService _loaderService = LoaderService();
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      _loaderService.showLoader(context);
      _loginService.silentlyLogin().then((value) {
        if (value != null) {
          setState(() => isLoggedIn = true);
        }
        // Future.delayed(
        //     const Duration(seconds: 5), () => _loaderService.hideLoader());
        _loaderService.hideLoader();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      return MainTabs(
        title: widget.title,
        onLogout: () => _loginService.logout().then(
              (value) => setState(() => isLoggedIn = false),
            ),
      );
    }
    return Login(
      title: widget.title,
      onLogin: () => _loginService.login().then((value) {
        if (value != null) {
          setState(() => isLoggedIn = true);
        }
      }),
    );
  }
}
