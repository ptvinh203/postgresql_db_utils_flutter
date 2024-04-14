extension StringExt on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  String get wrapString => "'$this'";

  String get log => "PostgreSQL_Db_Utils (ptvinh203): \n\t $this \n";
}
