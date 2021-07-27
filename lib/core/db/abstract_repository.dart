import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/core/db/database_manager.dart';
import 'package:every_calendar/core/db/pagination.dart';
import 'package:flutter/material.dart';

abstract class AbstractRepository<T extends AbstractEntity> {
  @protected
  final DatabaseManager databaseManager = DatabaseManager();

  T getEntityInstance();

  Future<List<T>> getAll() async {
    return await getAllFiltered();
  }

  @protected
  Future<List<T>> getAllFiltered({
    String where = '',
    List<dynamic>? whereArgs,
  }) async {
    var entity = getEntityInstance();
    String table = entity.getTableName();
    var result = await databaseManager.getAll(
      table,
      where: where,
      whereArgs: whereArgs,
    );
    if (result != null) {
      return result.map((e) => entity.fromMap(e) as T).toList();
    }
    return List.empty();
  }

  Future<Pagination<T>> getAllPaginated(int limit, int offset) async {
    return await getAllPaginatedFiltered(limit, offset);
  }

  @protected
  Future<Pagination<T>> getAllPaginatedFiltered(
    int limit,
    int offset, {
    String where = '',
    List<dynamic>? whereArgs,
  }) async {
    var entity = getEntityInstance();
    String table = entity.getTableName();
    var result = await databaseManager.getAllPaginated(
      table,
      limit,
      offset,
      where: where,
      whereArgs: whereArgs,
    );
    if (result != null) {
      var count = await databaseManager.count(
        table,
        where: where,
        whereArgs: whereArgs,
      );
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

  Future<T?> getByUuid(String uuid) async {
    var entity = getEntityInstance();
    String table = entity.getTableName();
    var result = await databaseManager.getByUuid(table, uuid);
    if (result != null) {
      return entity.fromMap(result) as T;
    }
    return null;
  }

  Future<T?> insert(T entity) async {
    String table = entity.getTableName();
    var result = await databaseManager.insert(table, entity);
    if (result != null) {
      return entity.fromMap(result) as T;
    }
    return null;
  }

  Future<T?> insertOrUpdate(T entity) async {
    String table = entity.getTableName();
    var result = await databaseManager.insertOrUpdate(table, entity);
    if (result != null) {
      return entity.fromMap(result) as T;
    }
    return null;
  }

  Future<T?> update(T entity) async {
    String table = entity.getTableName();
    var result = await databaseManager.update(table, entity.getUuid(), entity);
    if (result != null) {
      return entity.fromMap(result) as T;
    }
    return null;
  }

  Future<void> delete(T entity) async {
    String table = entity.getTableName();
    await databaseManager.logicalDeleteByUuid(table, entity.getUuid(), entity);
  }
}
