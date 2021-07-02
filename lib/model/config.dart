import 'dart:convert';

import 'package:every_calendar/model/tenant.dart';

Config configFromJson(String string) => Config.fromJson(jsonDecode(string));
String configToJson(Config config) => jsonEncode(config.toJson());

class Config {
  List<Tenant> tenants;

  Config(
    this.tenants,
  );

  Config.fromJson(Map<String, dynamic> json)
      : tenants = (json['tenants'] as List)
            .map(
              (e) => Tenant.fromJson(e),
            )
            .toList();

  Map<String, dynamic> toJson() => {
        'tenants': tenants.map((t) => t.toJson()).toList(),
      };
}
