import 'dart:convert';

Tenant tenantFromJson(String string) => Tenant.fromJson(jsonDecode(string));
String tenantToJson(Tenant tenant) => jsonEncode(tenant.toJson());

class Tenant {
  int id;
  String name;

  Tenant(
    this.id,
    this.name,
  );

  Tenant.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  bool operator ==(dynamic other) => other is Tenant && id == other.id;

  @override
  int get hashCode => super.hashCode;
}
