import 'package:every_calendar/core/db/database_setup.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DatabaseManager {
  Future<List<Map<String, dynamic>>?> getAll(String table) async {
    var db = await DatabaseSetup.getDatabase();
    return await db.query(table);
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
      String table, Map<String, dynamic> value) async {
    String? uuid = value['uuid'];

    if (uuid != null && uuid.isNotEmpty) {
      var row = await getByUuid(table, uuid);
      if (row != null) {
        return update(table, uuid, value);
      }
    }

    return insert(table, value);
  }

  Future<Map<String, dynamic>?> insert(
      String table, Map<String, dynamic> value) async {
    var db = await DatabaseSetup.getDatabase();

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
      String table, String uuid, Map<String, dynamic> value) async {
    var db = await DatabaseSetup.getDatabase();

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
