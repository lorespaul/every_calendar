import 'dart:convert';

import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/model/value_objects/time_range.dart';
import 'package:every_calendar/utils/date_time_ultils.dart';

Activity activityFromJson(String string) =>
    Activity.fromMap(jsonDecode(string));
String activityToJson(Activity activity) => jsonEncode(activity.toMap());

class Activity extends AbstractEntity {
  String uuid;
  String name;
  String? description;
  TimeRange duration;
  DateTime createdAt = DateTimeUtils.nowUtc();
  String createdBy;
  DateTime modifiedAt = DateTimeUtils.nowUtc();
  String modifiedBy;
  DateTime? deletedAt;
  String? deletedBy;
  String modifiedByDevice;

  Activity({
    this.uuid = '',
    this.name = '',
    this.description,
    this.duration = const TimeRange.zero(),
    this.createdBy = '',
    this.modifiedBy = '',
    this.modifiedByDevice = '',
  });

  @override
  String getUuid() => uuid;

  Activity.fromMap(Map<String, dynamic> json)
      : uuid = json['uuid'],
        name = json['name'],
        description = json['description'],
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
        'name': name,
        'description': description,
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
  String getTableName() => 'activities';

  @override
  AbstractEntity fromMap(Map<String, dynamic> value) => Activity.fromMap(value);

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
