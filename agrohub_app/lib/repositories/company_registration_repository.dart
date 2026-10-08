import 'package:agrohub_app/database/database_helper.dart';

class CompanyRegistrationRepository {
  const CompanyRegistrationRepository();

  Future<void> register(String table, Map<String, dynamic> values) async {
    if (!const {'fazendas', 'comercios'}.contains(table)) {
      throw ArgumentError.value(table);
    }
    final document = values['documento']?.toString() ?? '';
    if (document.isEmpty) throw StateError('Informe o CPF ou CNPJ da empresa.');
    for (final companyTable in const ['fazendas', 'comercios']) {
      final existing = await DatabaseHelper.instance.buscarPorColuna(
        companyTable, 'documento', document,
      );
      if (existing != null) {
        throw StateError('Já existe uma empresa cadastrada com este CPF ou CNPJ.');
      }
    }
    await DatabaseHelper.instance.inserirRegistro(table, values);
  }
}
