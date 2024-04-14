// ignore_for_file: unnecessary_getters_setters

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:postgres/postgres.dart';
import 'package:postgresql_db_utils/src/utils/string_ext.dart';

abstract class PostgresqlDb {
  late String _host;
  late String _database;
  late int _port;
  String? _username;
  String? _password;
  late Connection _con;

  // Constructor
  PostgresqlDb({
    required String host,
    required String database,
    int port = 5342,
    String? username,
    String? password,
  }) {
    _host = host;
    _database = database;
    _port = port;
    _username = username;
    _password = password;
    registerInstanceInGetIt(GetIt.instance);
  }

  // Setter & Getter
  set host(String host) => _host = host;
  String get host => _host;
  set database(String database) => _database = database;
  String get database => _database;
  set port(int port) => _port = port;
  int get port => _port;
  set username(String? username) => _username = username;
  String? get username => _username;
  set password(String? password) => _password = password;
  String? get password => _password;

  // abstract methods
  void registerInstanceInGetIt(GetIt instance);

  // Methods
  Future<void> openConnection() async {
    _con = await Connection.open(Endpoint(
      host: host,
      database: database,
      port: port,
      username: username,
      password: password,
    ));
  }

  Future<void> closeConnection() async => await _con.close();
  Future<Result?> execute(String query) async {
    try {
      await openConnection();
      return await _con.execute(query);
    } catch (e) {
      debugPrint("Execute query $query error: $e".log);
      rethrow;
    } finally {
      await closeConnection();
    }
  }
}
