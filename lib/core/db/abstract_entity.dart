abstract class AbstractEntity {
  String getTableName();

  String getUuid();

  DateTime getCreatedAt();
  DateTime getModifiedAt();
  DateTime? getDeletedAt();

  String getCreatedBy();
  String getModifiedBy();
  String? getDeletedBy();

  String getModifiedByDevice();

  Map<String, dynamic> toMap();
  AbstractEntity fromMap(Map<String, dynamic> value);
}
