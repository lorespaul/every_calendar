import 'dart:io';

import 'package:every_calendar/constants/prefs_keys.dart';
import 'package:every_calendar/model/config.dart';
import 'package:every_calendar/model/tenant.dart';
import 'package:every_calendar/services/drive_service.dart';
import 'package:every_calendar/services/filesystem_service.dart';
import 'package:every_calendar/widgets/scaffold_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TenantManager extends StatefulWidget {
  const TenantManager({
    Key? key,
    required this.title,
    required this.onSync,
  }) : super(key: key);

  final String title;
  final Function(String) onSync;

  @override
  State<StatefulWidget> createState() => _TenantManagerState();
}

class _TenantManagerState extends State<TenantManager> {
  final DriveService _driveService = DriveService();
  final FilesystemService _filesystemService = FilesystemService();
  SharedPreferences? _prefs;

  Config? _config;
  Tenant? _selectedTenant;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      title: widget.title,
      builder: () {
        return FutureBuilder<Config>(
          future: _getConfig(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Config config = snapshot.data!;
              return DropdownButton<Tenant>(
                hint: const Text('Select tenant'),
                value: _selectedTenant,
                onChanged: (v) async {
                  _prefs!.setInt(PrefsKeys.tenant, v!.id);
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
        onPressed: () async {
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
    if (_config == null) {
      File configFile = await _filesystemService.getTenantFile();
      await _driveService.syncTenants(configFile);
      var fileValue = await _filesystemService.getTenantFileJson();
      _config = configFromJson(fileValue);
    }
    _prefs ??= await SharedPreferences.getInstance();
    var tenantId = _prefs!.getInt(PrefsKeys.tenant);
    if (tenantId != null) {
      _selectedTenant = _config!.tenants.firstWhereOrNull(
        (e) => e.id == tenantId,
      );
    }
    return _config!;
  }
}
