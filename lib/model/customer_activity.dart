import 'dart:convert';

import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/model/value_objects/time_range.dart';
import 'package:every_calendar/utils/date_time_ultils.dart';

CustomerActivity customerActivityFromJson(String string) =>
    CustomerActivity.fromMap(jsonDecode(string));
String customerActivityToJson(CustomerActivity customerActivity) =>
    jsonEncode(customerActivity.toMap());

class CustomerActivity extends AbstractEntity {
  String uuid;
  String? uuidCustomer;
  String? uuidActivity;
  TimeRange duration;
  DateTime createdAt = DateTimeUtils.nowUtc();
  String createdBy;
  DateTime modifiedAt = DateTimeUtils.nowUtc();
  String modifiedBy;
  DateTime? deletedAt;
  String? deletedBy;
  String modifiedByDevice;

  CustomerActivity({
    this.uuid = '',
    this.duration = const TimeRange.zero(),
    this.createdBy = '',
    this.modifiedBy = '',
    this.modifiedByDevice = '',
  });

  @override
  String getUuid() => uuid;

  CustomerActivity.fromMap(Map<String, dynamic> json)
      : uuid = json['uuid'],
        uuidCustomer = json['uuidCustomer'],
        uuidActivity = json['uuidActivity'],
        duration = TimeRange.fromMilliseconds(json['duration']),
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
        'uuidCustomer': uuidCustomer,
        'uuidActivity': uuidActivity,
        'duration': duration.toMilliseconds(),
        'createdAt': createdAt.millisecondsSinceEpoch,
        'createdBy': createdBy,
        'modifiedAt': modifiedAt.millisecondsSinceEpoch,
        'modifiedBy': modifiedBy,
        'deletedAt': deletedAt?.millisecondsSinceEpoch,
        'deletedBy': deletedBy,
        'modifiedByDevice': modifiedByDevice,
      };

  @override
  String getTableName() => 'customers_activities';

  @override
  AbstractEntity fromMap(Map<String, dynamic> value) =>
      CustomerActivity.fromMap(value);

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
