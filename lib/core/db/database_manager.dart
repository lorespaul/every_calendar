import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/core/db/database_setup.dart';
import 'package:every_calendar/utils/date_time_ultils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._internal();
  DatabaseManager._internal();

  factory DatabaseManager() {
    return _instance;
  }

  static String Function()? getOwner;
  Function(AbstractEntity, String)? onChange;

  Future<List<Map<String, dynamic>>?> getAll(
    String table, {
    DateTime? fromModifiedDate,
  }) async {
    var db = await DatabaseSetup.getDatabase();
    var where = 'deletedAt IS NULL';
    List<int>? args;
    if (fromModifiedDate != null) {
      where += ' AND modifiedAt > ?';
      args = [fromModifiedDate.millisecondsSinceEpoch];
    }
    return await db.query(
      table,
      where: where,
      whereArgs: args,
      orderBy: 'createdAt DESC',
    );
  }

  Future<List<Map<String, dynamic>>?> getAllPaginated(
      String table, int limit, int offset) async {
    var db = await DatabaseSetup.getDatabase();
    return await db.query(
      table,
      where: 'deletedAt IS NULL',
      limit: limit,
      offset: offset,
      orderBy: 'createdAt DESC',
    );
  }

  Future<int> count(String table) async {
    var db = await DatabaseSetup.getDatabase();
    var result = await db.rawQuery(
      '''
      SELECT COUNT(uuid) as c
      FROM $table 
      WHERE deletedAt IS NULL
      ''',
    );
    return result[0]['c'] as int;
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
    bool isSynchronizer = false,
  }) async {
    String? uuid = entity.getUuid();

    if (uuid.isNotEmpty) {
      var row = await getByUuid(table, uuid);
      if (row != null) {
        return update(
          table,
          uuid,
          entity,
          isSynchronizer: isSynchronizer,
        );
      }
    }

    return insert(
      table,
      entity,
      isSynchronizer: isSynchronizer,
    );
  }

  Future<Map<String, dynamic>?> insert(
    String table,
    AbstractEntity entity, {
    String uuid = '',
    bool isSynchronizer = false,
  }) async {
    var db = await DatabaseSetup.getDatabase();

    if (!isSynchronizer) {
      var now = DateTimeUtils.nowUtc();
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

    var result = await getById(table, id);
    if (result != null && !isSynchronizer) {
      onChange?.call(entity, result['uuid']);
    }
    return result;
  }

  Future<Map<String, dynamic>?> update(
    String table,
    String uuid,
    AbstractEntity entity, {
    bool isSynchronizer = false,
  }) async {
    var db = await DatabaseSetup.getDatabase();

    if (!isSynchronizer) {
      entity.setModifiedAt(DateTimeUtils.nowUtc());
      entity.setModifiedBy(DatabaseManager.getOwner!());
    }

    var value = entity.toMap();
    await db.update(
      table,
      value,
      where: 'uuid = ?',
      whereArgs: [uuid],
    );

    if (!isSynchronizer) {
      onChange?.call(entity, uuid);
    }
    return getByUuid(table, uuid);
  }

  Future<Map<String, dynamic>?> logicalDeleteByUuid(
    String table,
    String uuid,
    AbstractEntity entity, {
    bool isSynchronizer = false,
  }) async {
    var db = await DatabaseSetup.getDatabase();

    if (!isSynchronizer) {
      entity.setDeletedAt(DateTimeUtils.nowUtc());
      entity.setDeletedBy(DatabaseManager.getOwner!());
    }

    var value = entity.toMap();
    await db.update(
      table,
      value,
      where: 'uuid = ?',
      whereArgs: [uuid],
    );

    if (!isSynchronizer) {
      onChange?.call(entity, uuid);
    }
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
    String table,
    List<int> notIn, {
    DateTime? fromModifiedDate,
  }) async {
    var db = await DatabaseSetup.getDatabase();
    if (notIn.isEmpty) {
      return await getAll(table, fromModifiedDate: fromModifiedDate);
    }
    String questionMarks = List.generate(
      notIn.length,
      (index) => '?',
    ).join(', ');
    var where = 'id NOT IN ($questionMarks)';
    if (fromModifiedDate != null) {
      where += ' AND modifiedAt > ?';
      notIn.add(fromModifiedDate.millisecondsSinceEpoch);
    }
    return await db.query(
      table,
      where: where,
      whereArgs: notIn,
    );
  }
}
