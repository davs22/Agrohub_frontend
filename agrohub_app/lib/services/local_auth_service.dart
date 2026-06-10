import 'package:agrohub_app/database/database_helper.dart';

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

    return null;
  }
}
