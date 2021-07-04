import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/core/db/database_manager.dart';

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
    var result = await _databaseManager.insert(table, entity.toMap());
    if (result != null) {
      return entity.fromMap(result) as T;
    }
    return null;
  }

  Future<T?> insertOrUpdate(T entity) async {
    String table = entity.getTableName();
    var result = await _databaseManager.insertOrUpdate(table, entity.toMap());
    if (result != null) {
      return entity.fromMap(result) as T;
    }
    return null;
  }

  Future<T?> update(T entity) async {
    String table = entity.getTableName();
    var result =
        await _databaseManager.update(table, entity.getUuid(), entity.toMap());
    if (result != null) {
      return entity.fromMap(result) as T;
    }
    return null;
  }

  Future<void> delete(T entity) async {
    String table = entity.getTableName();
    await _databaseManager.deleteByUuid(table, entity.getUuid());
  }
}
