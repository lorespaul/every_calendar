import 'dart:convert';

Tenant tenantFromJson(String string) => Tenant.fromMap(jsonDecode(string));
String tenantToJson(Tenant tenant) => jsonEncode(tenant.toMap());

class Tenant {
  int id;
  String name;

  Tenant(
    this.id,
    this.name,
  );

  Tenant.fromMap(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
      };

  @override
  bool operator ==(dynamic other) => other is Tenant && id == other.id;

  @override
  int get hashCode => '$id\$\$$name'.hashCode;
}
