import 'package:every_calendar/core/google/config.dart';
import 'package:every_calendar/core/google/login_service.dart';
import 'package:every_calendar/core/google/tenant.dart';
import 'package:every_calendar/core/google/drive_manager.dart';
import 'package:every_calendar/core/shared/shared_constants.dart';
import 'package:every_calendar/widgets/scaffold_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tenants extends StatefulWidget {
  const Tenants({
    Key? key,
    required this.title,
    required this.onSync,
  }) : super(key: key);

  final String title;
  final Function(String) onSync;

  @override
  State<StatefulWidget> createState() => _TenantsState();
}

class _TenantsState extends State<Tenants> {
  final DriveManager _driveManager = DriveManager();
  final LoginService _loginService = LoginService();
  SharedPreferences? _prefs;

  Config? _config;
  Tenant? _selectedTenant;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      title: widget.title,
      builder: (ctx) {
        return FutureBuilder<Config>(
          future: _getConfig(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Config config = snapshot.data!;
              return DropdownButton<Tenant>(
                hint: const Text('Select tenant'),
                value: _selectedTenant,
                onChanged: (v) async {
                  _prefs!.setInt(SharedConstants.tenant, v!.id);
                  _prefs!.setBool(
                    SharedConstants.isTenant,
                    v.driveAccount == _loginService.loggedUser.email,
                  );
                  setState(() => _selectedTenant = v);
                },
                items: config.tenants.map((tenant) {
                  return DropdownMenuItem<Tenant>(
                    value: tenant,
                    child: Row(
                      children: <Widget>[
                        Text(
                          tenant.name,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            } else if (snapshot.hasError) {
              return const Text('Error');
            }
            return const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            );
          },
        );
      },
      actionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedTenant != null) {
            widget.onSync(_selectedTenant!.context);
          }
        },
        child: const Icon(Icons.sync),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<Config> _getConfig() async {
    _config ??= await _driveManager.getConfig();
    _prefs ??= await SharedPreferences.getInstance();
    var tenantId = _prefs!.getInt(SharedConstants.tenant);
    if (tenantId != null) {
      _selectedTenant = _config!.tenants.firstWhereOrNull(
        (e) => e.id == tenantId,
      );
    }
    return _config!;
  }
}
