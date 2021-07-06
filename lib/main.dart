import 'dart:io';

import 'package:every_calendar/constants/all_constants.dart';
import 'package:every_calendar/core/db/database_setup.dart';
import 'package:every_calendar/core/sync/sync_manager.dart';
import 'package:every_calendar/services/drive_service.dart';
import 'package:every_calendar/services/filesystem_service.dart';
import 'package:every_calendar/services/loader_service.dart';
import 'package:every_calendar/services/login_service.dart';
import 'package:every_calendar/widgets/login.dart';
import 'package:every_calendar/widgets/main_tabs.dart';
import 'package:every_calendar/widgets/menu/tenant_manger.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

import 'constants/prefs_keys.dart';
import 'core/db/abstract_entity.dart';
import 'model/collaborator.dart';
import 'model/config.dart';
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
  LoginService? _loginService;
  final DriveService _driveService = DriveService();
  final FilesystemService _filesystemService = FilesystemService();
  final LoaderService _loaderService = LoaderService();
  final SyncManager _syncManager = SyncManager();

  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loginService = LoginService(onLoggedIn: () {
      initTenant();
      isLoggedIn = true;
      setState(() {});
    });

    Future.delayed(Duration.zero, () {
      _loaderService.showLoader(context);
      _loginService!.silentlyLogin().then((value) {
        // if (value != null) {
        //   setState(() => isLoggedIn = true);
        // }
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
          _loginService!.logout().then((value) {
            setState(() => isLoggedIn = false);
            _loaderService.hideLoader();
          });
        },
        onSync: setupTenantAndSync,
      );
    }
    return Login(
      title: widget.title,
      onLogin: () => _loginService!.login().then((value) {
        if (value != null) {
          setState(() => isLoggedIn = true);
        }
      }),
    );
  }

  Future<void> setupTenantAndSync(
    String context,
    AbstractEntity? entity,
  ) async {
    if (context != AllConstants.currentContext) {
      await DatabaseSetup.setup(context, () => _loginService!.loggedUser.email);
    } else {
      context = DatabaseSetup.getContext();
    }
    List<AbstractEntity> collections = entity == null
        ? [
            Collaborator(),
            Customer(),
          ]
        : [entity];
    var driveApi = await _driveService.getDriveApi();
    _syncManager
      ..tenantFolder = context
      ..collections = collections
      ..driveApi = driveApi
      ..loggedUser = _loginService!.loggedUser;
    return await _syncManager.synchronize();
  }

  Future<void> initTenant() async {
    File configFile = await _filesystemService.getTenantFile();
    await _driveService.syncTenants(configFile);
    var fileValue = await _filesystemService.getTenantFileJson();
    var config = configFromJson(fileValue);
    var prefs = await SharedPreferences.getInstance();
    var tenantId = prefs.getInt(PrefsKeys.tenant);
    if (tenantId != null) {
      var selectedTenant = config.tenants.firstWhereOrNull(
        (e) => e.id == tenantId,
      );
      await setupTenantAndSync(selectedTenant!.context, null);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return TenantManager(
              title: widget.title,
              onSync: (c) {
                setupTenantAndSync(c, null);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (c) => widget),
                );
              },
            );
          },
        ),
      );
    }
  }
}
