import 'package:flutter/material.dart';
import 'package:postgresql_db_utils/src/entity.dart';
import 'package:postgresql_db_utils/src/query.dart';
import 'package:postgresql_db_utils/src/query_type.dart';

class BaseRepository<T extends Entity, ID> {
  late final String _tableName;
  late T Function() _getInstance;

  BaseRepository(
      {required String tableName, required T Function() getInstance}) {
    _tableName = tableName;
    _getInstance = getInstance;
  }

  // Getters
  String get tableName => _tableName;

  Future<T?> save(T data, {bool isUpdate = false}) async {
    var query = isUpdate
        ? (Query<T>(type: QueryType.update, tableName: _tableName)
          ..value(data)
          ..where(
              "${data.getPrimaryKey.entries.first.key}=${data.getPrimaryKey.entries.first.value}"))
        : Query<T>(type: QueryType.insert, tableName: _tableName)
      ..value(data..id = data.generateId());
    if (!data.isValid()) {
      throw Exception("Data is not valid: ${data.toValueMap(true)}");
    }
    var resultRow = (await query.commit()).firstOrNull;
    return resultRow != null ? _getInstance().fromResultRow(resultRow) : null;
  }

  Future<List<T>> saveAll(List<T> data) async {
    List<T> results = [];
    for (var item in data) {
      try {
        var result = await save(item);
        if (result != null) results.add(result);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return results;
  }

  Future<List<T>> findAll() async {
    var query = Query<T>(type: QueryType.select, tableName: _tableName);
    return (await query.commit())
        .map((e) => _getInstance().fromResultRow(e) as T)
        .toList();
  }

  Future<T?> findById(ID id) async {
    var query = Query<T>(type: QueryType.select, tableName: _tableName)
      ..where("id=$id");
    var resultRow = (await query.commit()).firstOrNull;
    return resultRow != null ? _getInstance().fromResultRow(resultRow) : null;
  }

  void deleteAll() async =>
      Query<T>(type: QueryType.delete, tableName: _tableName).commit();

  void deleteById(ID id) async {
    var query = Query<T>(type: QueryType.delete, tableName: _tableName)
      ..where("id=$id");
    await query.commit();
  }
}
