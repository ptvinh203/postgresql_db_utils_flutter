// ignore_for_file: unnecessary_getters_setters

import 'package:postgres/postgres.dart';

abstract class Entity<T, ID> {
  ID? _id;

  // Constructor
  Entity({ID? id}) {
    _id = id;
  }

  // Setter & Getter
  set id(ID? id) => _id = id;
  ID? get id => _id;

  Map<String, String> get getPrimaryKey;

  ID generateId();

  bool isValid();

  Map<String, String> toValueMap(bool includePrimaryKey);

  T fromResultRow(ResultRow resultRow);
}
