// ignore_for_file: unnecessary_getters_setters

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:postgres/postgres.dart';
import 'package:postgresql_db_utils/src/entity.dart';
import 'package:postgresql_db_utils/src/postgresql_db.dart';
import 'package:postgresql_db_utils/src/query_type.dart';
import 'package:postgresql_db_utils/src/utils/string_ext.dart';

class Query<T extends Entity> {
  late PostgresqlDb _db;
  late final QueryType _type;
  late final String _tableName;
  final List<String> _conditions = [];
  T? entity;
  String _query = '';

  // Constructor
  Query({required QueryType type, required String tableName}) {
    _type = type;
    _tableName = tableName;
    switch (type) {
      case QueryType.insert:
        _query = 'INSERT INTO $_tableName';
        break;
      case QueryType.update:
        _query = 'UPDATE $_tableName';
        break;
      case QueryType.delete:
        _query = 'DELETE FROM $_tableName';
        break;
      case QueryType.select:
        _query = 'SELECT * FROM $_tableName';
        break;
      default:
        throw Exception('Invalid Query Type');
    }

    // Get PostgresqlDb instance from GetIt
    try {
      _db = GetIt.instance.get<PostgresqlDb>();
    } catch (e) {
      debugPrint("Don't have PostgresqlDb instance in GetIt!".log);
    }
  }

  // Getter
  QueryType get type => _type;
  String get tableName => _tableName;

  // Methods
  Query where(String condition) {
    if (type == QueryType.insert) {
      throw Exception("QueryType INSERT can not have a WHERE clause");
    }
    _conditions.add(condition);
    return this;
  }

  Query<T> value(T value) {
    entity = value;
    return this;
  }

  Future<List<ResultRow>> commit() async {
    try {
      var finalQuery = _makeQueryString();
      debugPrint(finalQuery.log);
      var result = await _db.execute(finalQuery);
      return (result ?? []).map((e) => e as ResultRow).toList();
    } catch (_) {
      rethrow;
    }
  }

  String _makeQueryString() {
    String finalQueryString = _query;
    switch (type) {
      case QueryType.insert:
        if (entity == null) {
          throw Exception("QueryType INSERT must have a value");
        }
        finalQueryString +=
            "(${entity!.toValueMap(true).keys.join(",")}) VALUES (${entity!.toValueMap(true).values.join(",")})";
        break;
      case QueryType.update:
        if (entity == null) {
          throw Exception("QueryType UPDATE must have a value");
        }
        finalQueryString +=
            " SET ${entity!.toValueMap(false).entries.map((e) => "${e.key}=${e.value}").join(",")}";
        break;
      default:
        break;
    }
    if (_conditions.isNotEmpty) {
      finalQueryString += " WHERE ${_conditions.join(" AND ")}";
    }
    return finalQueryString;
  }
}
