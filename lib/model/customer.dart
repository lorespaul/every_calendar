import 'dart:convert';

import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/utils/date_time_ultils.dart';

Customer customerFromJson(String string) =>
    Customer.fromMap(jsonDecode(string));
String customerToJson(Customer customer) => jsonEncode(customer.toMap());

class Customer extends AbstractEntity {
  String uuid;
  String name;
  String email;
  DateTime createdAt = DateTimeUtils.nowUtc();
  String createdBy;
  DateTime modifiedAt = DateTimeUtils.nowUtc();
  String modifiedBy;
  DateTime? deletedAt;
  String? deletedBy;
  String modifiedByDevice;

  Customer({
    this.uuid = '',
    this.name = '',
    this.email = '',
    this.createdBy = '',
    this.modifiedBy = '',
    this.modifiedByDevice = '',
  });

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
        modifiedBy = json['modifiedBy'],
        deletedAt = json['deletedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['deletedAt'])
            : null,
        deletedBy = json['deletedBy'],
        modifiedByDevice = json['modifiedByDevice'];

  @override
  Map<String, dynamic> toMap() => {
        'uuid': uuid,
        'name': name,
        'email': email,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'createdBy': createdBy,
        'modifiedAt': modifiedAt.millisecondsSinceEpoch,
        'modifiedBy': modifiedBy,
        'deletedAt': deletedAt?.millisecondsSinceEpoch,
        'deletedBy': deletedBy,
        'modifiedByDevice': modifiedByDevice,
      };

  @override
  String getTableName() => 'customers';

  @override
  AbstractEntity fromMap(Map<String, dynamic> value) => Customer.fromMap(value);

  @override
  DateTime getCreatedAt() => createdAt;
  @override
  String getCreatedBy() => createdBy;
  @override
  DateTime getModifiedAt() => modifiedAt;
  @override
  String getModifiedBy() => modifiedBy;
  @override
  DateTime? getDeletedAt() => deletedAt;
  @override
  String? getDeletedBy() => deletedBy;

  @override
  String getModifiedByDevice() => modifiedByDevice;
}
