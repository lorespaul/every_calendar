import 'package:every_calendar/constants/all_constants.dart';
import 'package:every_calendar/core/db/database_setup.dart';
import 'package:every_calendar/core/shared/shared_constants.dart';
import 'package:every_calendar/core/sync/sync_manager.dart';
import 'package:every_calendar/core/google/drive_manager.dart';
import 'package:every_calendar/controllers/loader_controller.dart';
import 'package:every_calendar/core/google/login_service.dart';
import 'package:every_calendar/widgets/login.dart';
import 'package:every_calendar/widgets/main_tabs.dart';
import 'package:every_calendar/widgets/tenants/tenants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

import 'core/db/abstract_entity.dart';
import 'model/collaborator.dart';
import 'model/customer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Every Calendar',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomePage(title: 'Every Calendar'),
      debugShowCheckedModeBanner: false,
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
  final DriveManager _driveManager = DriveManager();
  final LoaderController _loaderController = LoaderController();
  final SyncManager _syncManager = SyncManager();

  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loginService.onLoggedIn = () async {
      await initTenant();
      _loaderController.hideLoader();
      setState(() => isLoggedIn = true);
    };

    Future.delayed(Duration.zero, () {
      _loaderController.showLoader(context);
      _loginService.silentlyLogin().then((value) {
        if (value != null) {
          setState(() => isLoggedIn = true);
        }
        _loaderController.hideLoader();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      return MainTabs(
        title: widget.title,
        onLogout: () {
          _loaderController.showLoader(context);
          _loginService.logout().then((value) {
            setState(() => isLoggedIn = false);
            _loaderController.hideLoader();
          });
        },
        onSync: setupTenantAndSync,
      );
    }
    return Login(
      title: widget.title,
      onLogin: () => _loginService.login(),
    );
  }

  Future<void> setupTenantAndSync(
    String context,
    AbstractEntity? entity,
  ) async {
    if (context != AllConstants.currentContext) {
      await DatabaseSetup.setup(context, () => _loginService.loggedUser.email);
    } else {
      context = DatabaseSetup.getContext();
    }
    List<AbstractEntity> collections = entity == null
        ? [
            Collaborator(),
            Customer(),
          ]
        : [entity];
    _syncManager
      ..tenantFolder = context
      ..collections = collections;
    return _syncManager.synchronize();
  }

  Future<void> initTenant() async {
    var config = await _driveManager.getConfig();
    var prefs = await SharedPreferences.getInstance();
    var tenantId = prefs.getInt(SharedConstants.tenant);
    if (tenantId != null) {
      var selectedTenant = config!.tenants.firstWhereOrNull(
        (e) => e.id == tenantId,
      );
      await setupTenantAndSync(selectedTenant!.context, null);
    } else {
      chooseTenant();
    }
  }

  chooseTenant() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Tenants(
            onSync: (c) async {
              setupTenantAndSync(c, null);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (c) {
                  return HomePage(title: widget.title);
                }),
              );
            },
          );
        },
      ),
    );
  }
}
