abstract class AbstractEntity {
  String getTableName();
  String getUuid();
  void setUuid(String uuid);
  Map<String, dynamic> toMap();
  AbstractEntity fromMap(Map<String, dynamic> value);
}
