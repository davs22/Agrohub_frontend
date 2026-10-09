import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/models/local_account.dart';

abstract class AccountRepository {
  Future<LocalAccount?> findById(String table, int id);
  Future<LocalAccount?> findByDocument(String table, String document);
  Future<bool> changePassword(LocalAccount account, String column,
      String currentPassword, String newPassword);
  Future<void> deleteCompany(LocalAccount company, String adminPassword);
  Future<List<String>> ownedOperatorDocuments(LocalAccount company);
}

class SqliteAccountRepository implements AccountRepository {
  const SqliteAccountRepository();

  @override
  Future<LocalAccount?> findById(String table, int id) async {
    if (!const {'fazendas', 'comercios', 'operadores'}.contains(table)) return null;
    final row = await DatabaseHelper.instance.buscarPorId(table, id);
    return row == null ? null : LocalAccount.fromMap(table, row);
  }

  @override
  Future<LocalAccount?> findByDocument(String table, String document) async {
    if (!const {'fazendas', 'comercios', 'operadores'}.contains(table)) return null;
    final row = await DatabaseHelper.instance.buscarPorColuna(
        table, table == 'operadores' ? 'cpf' : 'documento', document);
    return row == null ? null : LocalAccount.fromMap(table, row);
  }

  @override
  Future<bool> changePassword(LocalAccount account, String column,
      String currentPassword, String newPassword) async =>
      DatabaseHelper.instance.changePassword(
        table: account.table,
        id: account.id,
        document: account.document,
        column: column,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

  @override
  Future<void> deleteCompany(LocalAccount company, String adminPassword) =>
      DatabaseHelper.instance.deleteCompany(company.table, company.id,
          company.document, adminPassword);

  @override
  Future<List<String>> ownedOperatorDocuments(LocalAccount company) async {
    final rows = await DatabaseHelper.instance.listarComFiltro('operadores',
        where: 'documento_admin = ?', whereArgs: [company.document]);
    return rows.map((row) => row['cpf'].toString()).toList();
  }
}
