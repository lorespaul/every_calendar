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
        primarySwatch: Colors.green,
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
        onLogout: () {
          _loaderService.showLoader(context);
          _loginService.logout().then((value) {
            setState(() => isLoggedIn = false);
            _loaderService.hideLoader();
          });
        },
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
