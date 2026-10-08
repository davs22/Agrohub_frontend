class CompanyProfile {
  const CompanyProfile({required this.table, required this.record});

  final String table;
  final Map<String, dynamic> record;

  int get id => record['id_local'] as int;
  String get document => record['documento'].toString();
  String get name => record['nome']?.toString() ?? '';
  bool get isFarm => table == 'fazendas';
  String get key => '$table:$document';
}
