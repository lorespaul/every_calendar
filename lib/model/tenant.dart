import 'dart:convert';

Tenant tenantFromJson(String string) => Tenant.fromMap(jsonDecode(string));
String tenantToJson(Tenant tenant) => jsonEncode(tenant.toMap());

class Tenant {
  int id;
  String name;
  String driveAccount;
  String context;

  Tenant(
    this.id,
    this.name,
    this.driveAccount,
    this.context,
  );

  Tenant.fromMap(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        driveAccount = json['driveAccount'],
        context = json['context'];

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'driveAccount': driveAccount,
        'context': context,
      };

  @override
  bool operator ==(dynamic other) => other is Tenant && id == other.id;

  @override
  int get hashCode => '$id\$\$$name'.hashCode;
}
