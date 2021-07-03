import 'dart:convert';

Collaborator tenantFromJson(String string) =>
    Collaborator.fromJson(jsonDecode(string));
String tenantToJson(Collaborator collaborator) =>
    jsonEncode(collaborator.toJson());

class Collaborator {
  int? id;
  String? name;
  String? email;

  Collaborator({
    this.id,
    this.name,
    this.email,
  });

  Collaborator.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        email = json['email'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };
}
