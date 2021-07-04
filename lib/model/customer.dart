import 'dart:convert';

import 'package:every_calendar/core/db/abstract_entity.dart';

Customer customerFromJson(String string) =>
    Customer.fromMap(jsonDecode(string));
String customerToJson(Customer customer) => jsonEncode(customer.toMap());

class Customer extends AbstractEntity {
  String uuid;
  String name;
  String email;
  DateTime createdAt = DateTime.now();
  String createdBy;
  DateTime modifiedAt = DateTime.now();
  String modifiedBy;

  Customer(
      {this.uuid = '',
      this.name = '',
      this.email = '',
      this.createdBy = '',
      this.modifiedBy = ''});

  @override
  String getUuid() => uuid;
  @override
  void setUuid(String uuid) => this.uuid = uuid;

  Customer.fromMap(Map<String, dynamic> json)
      : uuid = json['uuid'],
        name = json['name'],
        email = json['email'],
        createdAt = DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
        createdBy = json['createdBy'],
        modifiedAt = DateTime.fromMillisecondsSinceEpoch(json['modifiedAt']),
        modifiedBy = json['modifiedBy'];

  @override
  Map<String, dynamic> toMap() => {
        'uuid': uuid,
        'name': name,
        'email': email,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'createdBy': createdBy,
        'modifiedAt': modifiedAt.millisecondsSinceEpoch,
        'modifiedBy': modifiedBy,
      };

  @override
  String getTableName() => 'customers';

  @override
  AbstractEntity fromMap(Map<String, dynamic> value) => Customer.fromMap(value);
}
