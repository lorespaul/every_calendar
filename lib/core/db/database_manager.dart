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

  Future<Map<String, dynamic>?> getById(String table, int id) async {
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
    String table,
    AbstractEntity entity, {
    bool setBreadcrumbs = true,
  }) async {
    String? uuid = entity.getUuid();

    if (uuid.isNotEmpty) {
      var row = await getByUuid(table, uuid);
      if (row != null) {
        return update(
          table,
          uuid,
          entity,
          setBreadcrumbs: setBreadcrumbs,
        );
      }
    }

    return insert(
      table,
      entity,
      setBreadcrumbs: setBreadcrumbs,
    );
  }

  Future<Map<String, dynamic>?> insert(
    String table,
    AbstractEntity entity, {
    String uuid = '',
    bool setBreadcrumbs = true,
  }) async {
    var db = await DatabaseSetup.getDatabase();

    if (setBreadcrumbs) {
      var now = DateTime.now();
      entity.setCreatedAt(now);
      entity.setCreatedBy(DatabaseManager.getOwner!());
      entity.setModifiedAt(now);
      entity.setModifiedBy(DatabaseManager.getOwner!());
    }

    var value = entity.toMap();
    value['id'] = null;
    if (uuid.isEmpty) {
      var uuidGenerator = const Uuid();
      value['uuid'] = uuidGenerator.v4();
    } else {
      value['uuid'] = uuid;
    }
    int id = await db.insert(
      table,
      value,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return getById(table, id);
  }

  Future<Map<String, dynamic>?> update(
    String table,
    String uuid,
    AbstractEntity entity, {
    bool setBreadcrumbs = true,
  }) async {
    var db = await DatabaseSetup.getDatabase();

    if (setBreadcrumbs) {
      entity.setModifiedAt(DateTime.now());
      entity.setModifiedBy(DatabaseManager.getOwner!());
    }

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
    String table,
    String uuid,
    AbstractEntity entity,
  ) async {
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

  /// Don't call this method if you don't know what you are doing.
  ///
  /// This is used only by synchronizer.
  /// Use [logicalDeleteByUuid] instead!
  Future<void> deleteByUuid(String table, String uuid) async {
    var db = await DatabaseSetup.getDatabase();

    await db.delete(
      table,
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }

  Future<List<Map<String, dynamic>>?> getAllNotInId(
      String table, List<int> notIn) async {
    var db = await DatabaseSetup.getDatabase();
    if (notIn.isEmpty) {
      return await getAll(table);
    }
    String questionMarks = List.generate(
      notIn.length,
      (index) => '?',
    ).join(', ');
    return await db.query(
      table,
      where: 'id NOT IN ($questionMarks)',
      whereArgs: notIn,
    );
  }
}
