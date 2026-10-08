import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/models/company_profile.dart';
import 'package:agrohub_app/models/financial_entry.dart';
import 'package:agrohub_app/repositories/company_repository.dart';

class FinanceRepository {
  FinanceRepository({CompanyRepository? companies})
      : _companies = companies ?? CompanyRepository();

  final CompanyRepository _companies;

  Future<CompanyProfile> _requireCompany() async {
    final company = await _companies.current();
    if (company == null) {
      throw StateError('A gestão financeira está disponível para o administrador.');
    }
    return company;
  }

  Future<List<FinancialEntry>> load() async {
    final company = await _requireCompany();
    final rows = await DatabaseHelper.instance.listarComFiltro(
      'lancamentos_financeiros',
      where: 'empresa_chave = ?',
      whereArgs: [company.key],
      orderBy: 'data_movimento DESC, id_local DESC',
    );
    return rows.map(FinancialEntry.fromMap).toList();
  }

  Future<void> save(FinancialEntry entry) async {
    final company = await _requireCompany();
    if (entry.description.trim().isEmpty || entry.category.trim().isEmpty || entry.amountCents <= 0) {
      throw ArgumentError('Informe descrição, categoria e valor maior que zero.');
    }
    if (entry.id == null) {
      await DatabaseHelper.instance.inserirRegistro(
        'lancamentos_financeiros', entry.toMap(company.key),
      );
      return;
    }
    final db = await DatabaseHelper.instance.database;
    final changed = await db.update(
      'lancamentos_financeiros',
      {...entry.toMap(company.key), 'data_atualizacao': DateTime.now().toIso8601String()},
      where: 'id_local = ? AND empresa_chave = ?',
      whereArgs: [entry.id, company.key],
    );
    if (changed == 0) throw StateError('Lançamento não encontrado nesta empresa.');
  }

  Future<void> delete(int id) async {
    final company = await _requireCompany();
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'lancamentos_financeiros',
      where: 'id_local = ? AND empresa_chave = ?',
      whereArgs: [id, company.key],
    );
  }
}
