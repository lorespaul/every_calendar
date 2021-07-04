import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/core/db/database_setup.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DatabaseManager {
  static String Function()? getOwner;

  Future<List<Map<String, dynamic>>?> getAll(String table) async {
    var db = await DatabaseSetup.getDatabase();
    return await db.query(table, where: 'deletedAt IS NULL');
  }

  Future<Map<String, dynamic>?> getByUuid(String table, String uuid) async {
    var db = await DatabaseSetup.getDatabase();

    var result = await db.query(
      table,
      where: 'uuid = ?',
      whereArgs: [uuid],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<Map<String, dynamic>?> _getById(String table, int id) async {
    var db = await DatabaseSetup.getDatabase();

    var result = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<Map<String, dynamic>?> insertOrUpdate(
      String table, AbstractEntity entity) async {
    String? uuid = entity.getUuid();

    if (uuid.isNotEmpty) {
      var row = await getByUuid(table, uuid);
      if (row != null) {
        return update(table, uuid, entity);
      }
    }

    return insert(table, entity);
  }

  Future<Map<String, dynamic>?> insert(
      String table, AbstractEntity entity) async {
    var db = await DatabaseSetup.getDatabase();

    var now = DateTime.now();
    entity.setCreatedAt(now);
    entity.setCreatedBy(DatabaseManager.getOwner!());
    entity.setModifiedAt(now);
    entity.setModifiedBy(DatabaseManager.getOwner!());

    var value = entity.toMap();
    value['id'] = null;
    var uuidGenerator = const Uuid();
    value['uuid'] = uuidGenerator.v4();
    int id = await db.insert(
      table,
      value,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return _getById(table, id);
  }

  Future<Map<String, dynamic>?> update(
      String table, String uuid, AbstractEntity entity) async {
    var db = await DatabaseSetup.getDatabase();

    entity.setModifiedAt(DateTime.now());
    entity.setModifiedBy(DatabaseManager.getOwner!());

    var value = entity.toMap();
    await db.update(
      table,
      value,
      where: 'uuid = ?',
      whereArgs: [uuid],
    );

    return getByUuid(table, uuid);
  }

  Future<Map<String, dynamic>?> logicalDeleteByUuid(
      String table, String uuid, AbstractEntity entity) async {
    var db = await DatabaseSetup.getDatabase();

    entity.setDeletedAt(DateTime.now());
    entity.setDeletedBy(DatabaseManager.getOwner!());

    var value = entity.toMap();
    await db.update(
      table,
      value,
      where: 'uuid = ?',
      whereArgs: [uuid],
    );

    return getByUuid(table, uuid);
  }

  Future<void> deleteByUuid(String table, String uuid) async {
    var db = await DatabaseSetup.getDatabase();

    await db.delete(
      table,
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }
}
