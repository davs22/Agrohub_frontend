import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/models/company_profile.dart';
import 'package:agrohub_app/services/session_service.dart';

class CompanyRepository {
  Future<CompanyProfile?> current() async {
    final session = await SessionService.loadSession();
    if (session == null ||
        !session.isAdmin ||
        !['fazendas', 'comercios'].contains(session.tableName)) {
      return null;
    }
    final record = await DatabaseHelper.instance.buscarPorColuna(
      session.tableName,
      'documento',
      session.documento ?? session.login,
    );
    return record == null
        ? null
        : CompanyProfile(table: session.tableName, record: record);
  }

  Future<void> update(CompanyProfile company, Map<String, dynamic> values) async {
    final active = await current();
    if (active == null || active.key != company.key) {
      throw StateError('Acesso da empresa não encontrado. Entre novamente.');
    }
    final allowed = {
      'nome', 'telefone', 'email', 'status',
      if (company.isFarm) ...['hectares', 'latitude', 'longitude'],
      if (!company.isFarm) ...['cep', 'rua'],
    };
    final payload = Map<String, dynamic>.fromEntries(
      values.entries.where((entry) => allowed.contains(entry.key)),
    );
    await DatabaseHelper.instance.atualizarRegistro(
      company.table, payload, company.id,
    );
    final session = await SessionService.loadSession();
    if (session == null) return;
    await SessionService.saveSession(
      role: session.role,
      login: session.login,
      tableName: session.tableName,
      flowStage: session.flowStage,
      localId: session.localId,
      displayName: values['nome']?.toString() ?? session.displayName,
      documento: session.documento,
      token: session.token,
    );
  }
}
