import 'dart:io';

import 'package:every_calendar/model/config.dart';
import 'package:every_calendar/model/tenant.dart';
import 'package:every_calendar/services/drive_service.dart';
import 'package:every_calendar/services/filesystem_service.dart';
import 'package:every_calendar/widgets/scaffold_wrapper.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

class TenantManager extends StatefulWidget {
  TenantManager({Key? key, required this.title}) : super(key: key);

  final String title;
  final DriveService _driveService = DriveService();
  final FilesystemService _filesystemService = FilesystemService();

  @override
  State<StatefulWidget> createState() => _TenantManagerState();
}

class _TenantManagerState extends State<TenantManager> {
  Config? _config;
  Tenant? _selectedConfig;

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
                value: _selectedConfig,
                onChanged: (v) => setState(() => _selectedConfig = v),
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
    );
  }

  Future<Config> _getConfig() async {
    if (_config == null) {
      File configFile = await widget._filesystemService.getTenantFile();
      await widget._driveService.syncTenants(configFile);
      var fileValue = await widget._filesystemService.getTenantFileJson();
      _config = configFromJson(fileValue);
    }
    return _config!;
  }
}
