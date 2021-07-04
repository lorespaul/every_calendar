abstract class AbstractEntity {
  String getTableName();

  String getUuid();
  void setUuid(String uuid);

  DateTime getCreatedAt();
  void setCreatedAt(DateTime createdAt);
  DateTime getModifiedAt();
  void setModifiedAt(DateTime modifiedAt);
  DateTime? getDeletedAt();
  void setDeletedAt(DateTime? deletedAt);

  String getCreatedBy();
  void setCreatedBy(String createdBy);
  String getModifiedBy();
  void setModifiedBy(String modifiedBy);
  String? getDeletedBy();
  void setDeletedBy(String? deletedBy);

  Map<String, dynamic> toMap();
  AbstractEntity fromMap(Map<String, dynamic> value);
}
