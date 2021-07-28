import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/core/db/database_setup.dart';
import 'package:every_calendar/utils/date_time_ultils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._internal();
  DatabaseManager._internal();

  static const String _id = 'id';
  static const String _uuid = 'uuid';
  static const String _createdBy = 'createdBy';
  static const String _createdAt = 'createdAt';
  static const String _modifiedBy = 'modifiedBy';
  static const String _modifiedAt = 'modifiedAt';
  static const String _deletedBy = 'deletedBy';
  static const String _deletedAt = 'deletedAt';
  static const String _modifiedByDevice = 'modifiedByDevice';

  factory DatabaseManager() {
    return _instance;
  }

  static String Function()? getOwner;
  static String Function()? getDevice;
  Function(AbstractEntity, String)? onChange;

  Future<List<Map<String, dynamic>>?> getAll(
    String table, {
    DateTime? fromModifiedDate,
    String where = '',
    List<dynamic>? whereArgs,
  }) async {
    var db = await DatabaseSetup.getDatabase();
    var where = '';
    List<dynamic>? args;
    if (fromModifiedDate != null) {
      where += ' AND $_modifiedAt > ?';
      args = [fromModifiedDate.millisecondsSinceEpoch];
    }
    if (where != '') {
      where = ' AND ' + where;
      args = args ?? [];
      args.addAll(whereArgs!);
    }
    return await db.query(
      table,
      where: '$_deletedAt IS NULL' + where,
      whereArgs: args,
      orderBy: '$_createdAt DESC',
    );
  }

  Future<List<Map<String, dynamic>>?> getAllPaginated(
    String table,
    int limit,
    int offset, {
    String where = '',
    List<dynamic>? whereArgs,
  }) async {
    var db = await DatabaseSetup.getDatabase();
    if (where != '') {
      where = ' AND ' + where;
    }
    return await db.query(
      table,
      where: '$_deletedAt IS NULL' + where,
      whereArgs: whereArgs,
      limit: limit,
      offset: offset,
      orderBy: '$_createdAt DESC',
    );
  }

  Future<int> count(
    String table, {
    String where = '',
    List<dynamic>? whereArgs,
  }) async {
    var db = await DatabaseSetup.getDatabase();
    if (where != '') {
      where = ' AND ' + where;
      for (var arg in whereArgs!) {
        dynamic value = arg.toString();
        if (arg is String) {
          value = '\'' + value + '\'';
        } else if (arg is DateTime) {
          value = arg.millisecondsSinceEpoch;
        }
        where = where.replaceFirst(r'?', value);
      }
    }
    var result = await db.rawQuery(
      '''
      SELECT COUNT($_uuid) AS c
      FROM $table 
      WHERE $_deletedAt IS NULL
      ''' +
          where,
    );
    return result[0]['c'] as int;
  }

  /// Call this method only from repository.
  Future<List<Map<String, Object?>>> executeRawQuery(String sql) async {
    var db = await DatabaseSetup.getDatabase();
    return await db.rawQuery(sql);
  }

  Future<Map<String, dynamic>?> getByUuid(String table, String uuid) async {
    var db = await DatabaseSetup.getDatabase();

    var result = await db.query(
      table,
      where: '$_uuid = ?',
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
      where: '$_id = ?',
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

    var value = entity.toMap();
    if (!isSynchronizer) {
      var now = DateTimeUtils.nowUtc().millisecondsSinceEpoch;
      value[_createdAt] = now;
      value[_createdBy] = DatabaseManager.getOwner!();
      value[_modifiedAt] = now;
      value[_modifiedBy] = DatabaseManager.getOwner!();
      value[_modifiedByDevice] = DatabaseManager.getDevice!();
    }

    value[_id] = null;
    if (uuid.isEmpty) {
      var uuidGenerator = const Uuid();
      value[_uuid] = uuidGenerator.v4();
    } else {
      value[_uuid] = uuid;
    }
    int id = await db.insert(
      table,
      value,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    var result = await getById(table, id);
    if (result != null && !isSynchronizer) {
      onChange?.call(entity, result[_uuid]);
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

    var value = entity.toMap();
    if (!isSynchronizer) {
      value[_modifiedAt] = DateTimeUtils.nowUtc().millisecondsSinceEpoch;
      value[_modifiedBy] = DatabaseManager.getOwner!();
      value[_modifiedByDevice] = DatabaseManager.getDevice!();
    }

    await db.update(
      table,
      value,
      where: '$_uuid = ?',
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

    var value = entity.toMap();
    if (!isSynchronizer) {
      value[_deletedAt] = DateTimeUtils.nowUtc().millisecondsSinceEpoch;
      value[_deletedBy] = DatabaseManager.getOwner!();
    }

    await db.update(
      table,
      value,
      where: '$_uuid = ?',
      whereArgs: [uuid],
    );

    if (!isSynchronizer) {
      onChange?.call(entity, uuid);
    }
    return getByUuid(table, uuid);
  }

  Future<int> logicalDelete(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    var db = await DatabaseSetup.getDatabase();

    var value = {
      _deletedAt: DateTimeUtils.nowUtc().millisecondsSinceEpoch,
      _deletedBy: DatabaseManager.getOwner!(),
    };

    return await db.update(
      table,
      value,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Don't call this method if you don't know what you are doing.
  ///
  /// This is used only by synchronizer.
  /// Use [logicalDeleteByUuid] instead!
  Future<void> deleteByUuid(String table, String uuid) async {
    var db = await DatabaseSetup.getDatabase();

    await db.delete(
      table,
      where: '$_uuid = ?',
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
    var where = '$_id NOT IN ($questionMarks)';
    if (fromModifiedDate != null) {
      where += ' AND $_modifiedAt > ?';
      notIn.add(fromModifiedDate.millisecondsSinceEpoch);
    }
    return await db.query(
      table,
      where: where,
      whereArgs: notIn,
    );
  }
}
