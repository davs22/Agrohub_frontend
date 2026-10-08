import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/services/session_service.dart';

class LocalAuthResult {
  final String role;
  final String tableName;
  final Map<String, dynamic> record;

  const LocalAuthResult({
    required this.role,
    required this.tableName,
    required this.record,
  });
}

class LocalAuthService {
  static bool belongsToCompany(LocalAuthResult result, SessionData company) {
    if (!company.isCompanySession ||
        company.tableName !=
            (company.role == 'FAZENDA' ? 'fazendas' : 'comercios')) {
      return false;
    }
    final ownerDocument = result.tableName == 'operadores'
        ? result.record['documento_admin']
        : result.record['documento'];
    return ownerDocument?.toString() == company.documento &&
        (result.tableName == 'operadores' ||
            result.tableName == company.tableName);
  }

  static Future<LocalAuthResult?> _authenticateCompanyOperator(
    String tabela,
    String login,
    String password,
  ) async {
    final conta = await DatabaseHelper.instance.buscarPorColuna(
      tabela,
      'documento',
      login,
    );

    if (conta != null && conta['senha_operacao'] == password) {
      return LocalAuthResult(
        role: tabela == 'fazendas' ? 'FAZENDA' : 'COMERCIO',
        tableName: tabela,
        record: conta,
      );
    }

    return null;
  }

  static Future<LocalAuthResult?> authenticateAdmin(
    String login,
    String password,
  ) async {
    final comercio = await DatabaseHelper.instance.buscarPorColuna(
      'comercios',
      'documento',
      login,
    );

    if (comercio != null && comercio['senha_adm'] == password) {
      return LocalAuthResult(
        role: 'COMERCIO',
        tableName: 'comercios',
        record: comercio,
      );
    }

    final fazenda = await DatabaseHelper.instance.buscarPorColuna(
      'fazendas',
      'documento',
      login,
    );

    if (fazenda != null && fazenda['senha_adm'] == password) {
      return LocalAuthResult(
        role: 'FAZENDA',
        tableName: 'fazendas',
        record: fazenda,
      );
    }

    return null;
  }

  static Future<LocalAuthResult?> authenticateOperator(
    String login,
    String password,
  ) async {
    final operador = await DatabaseHelper.instance.buscarPorColuna(
      'operadores',
      'cpf',
      login,
    );

    if (operador != null && operador['senha'] == password) {
      return LocalAuthResult(
        role: 'OPERADOR',
        tableName: 'operadores',
        record: operador,
      );
    }

    final comercio =
        await _authenticateCompanyOperator('comercios', login, password);
    if (comercio != null) {
      return comercio;
    }

    final fazenda =
        await _authenticateCompanyOperator('fazendas', login, password);
    if (fazenda != null) {
      return fazenda;
    }

    return null;
  }
}
