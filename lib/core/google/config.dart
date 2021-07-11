import 'dart:convert';

import 'package:every_calendar/core/google/tenant.dart';

Config configFromJson(String string) => Config.fromMap(jsonDecode(string));
String configToJson(Config config) => jsonEncode(config.toMap());

class Config {
  List<Tenant> tenants;

  Config(
    this.tenants,
  );

  Config.fromMap(Map<String, dynamic> json)
      : tenants = (json['tenants'] as List)
            .map(
              (e) => Tenant.fromMap(e),
            )
            .toList();

  Map<String, dynamic> toMap() => {
        'tenants': tenants.map((t) => t.toMap()).toList(),
      };
}
