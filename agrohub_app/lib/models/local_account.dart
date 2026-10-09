class LocalAccount {
  const LocalAccount({
    required this.id,
    required this.table,
    required this.document,
    required this.status,
    required this.name,
    this.ownerDocument,
    this.adminPassword,
    this.operationPassword,
    this.operatorPassword,
  });

  final int id;
  final String table;
  final String document;
  final String status;
  final String name;
  final String? ownerDocument;
  final String? adminPassword;
  final String? operationPassword;
  final String? operatorPassword;

  bool get isActive => status.toUpperCase() == 'ATIVO';
  bool get isCompany => table == 'fazendas' || table == 'comercios';
  String get companyKey => '$table:$document';

  factory LocalAccount.fromMap(String table, Map<String, dynamic> row) =>
      LocalAccount(
        id: row['id_local'] as int,
        table: table,
        document: (row[table == 'operadores' ? 'cpf' : 'documento'] ?? '').toString(),
        status: (row['status'] ?? '').toString(),
        name: (row[table == 'operadores' ? 'nome_completo' : 'nome'] ?? '').toString(),
        ownerDocument: row['documento_admin']?.toString(),
        adminPassword: row['senha_adm']?.toString(),
        operationPassword: row['senha_operacao']?.toString(),
        operatorPassword: row['senha']?.toString(),
      );
}
