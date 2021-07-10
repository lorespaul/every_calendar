import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/core/db/database_manager.dart';
import 'package:every_calendar/core/db/pagination.dart';

class BaseRepository<T extends AbstractEntity> {
  final DatabaseManager _databaseManager = DatabaseManager();

  Future<List<T>> getAll(T entity) async {
    String table = entity.getTableName();
    var result = await _databaseManager.getAll(table);
    if (result != null) {
      return result.map((e) => entity.fromMap(e) as T).toList();
    }
    return List.empty();
  }

  Future<Pagination<T>> getAllPaginated(T entity, int limit, int offset) async {
    String table = entity.getTableName();
    var result = await _databaseManager.getAllPaginated(table, limit, offset);
    if (result != null) {
      var count = await _databaseManager.count(table);
      var deserialized = result.map((e) => entity.fromMap(e) as T).toList();
      return Pagination(
        result: deserialized,
        limit: limit,
        offset: offset,
        count: count,
      );
    }
    return Pagination(
      result: [],
      limit: limit,
      offset: offset,
      count: 0,
    );
  }

  Future<T?> getByUuid(T entity, String uuid) async {
    String table = entity.getTableName();
    var result = await _databaseManager.getByUuid(table, uuid);
    if (result != null) {
      return entity.fromMap(result) as T;
    }
    return null;
  }

  Future<T?> insert(T entity) async {
    String table = entity.getTableName();
    entity.setUuid('');
    var result = await _databaseManager.insert(table, entity);
    if (result != null) {
      return entity.fromMap(result) as T;
    }
    return null;
  }

  Future<T?> insertOrUpdate(T entity) async {
    String table = entity.getTableName();
    var result = await _databaseManager.insertOrUpdate(table, entity);
    if (result != null) {
      return entity.fromMap(result) as T;
    }
    return null;
  }

  Future<T?> update(T entity) async {
    String table = entity.getTableName();
    var result = await _databaseManager.update(table, entity.getUuid(), entity);
    if (result != null) {
      return entity.fromMap(result) as T;
    }
    return null;
  }

  Future<void> delete(T entity) async {
    String table = entity.getTableName();
    await _databaseManager.logicalDeleteByUuid(table, entity.getUuid(), entity);
  }
}
