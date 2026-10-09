import 'package:agrohub_app/models/local_account.dart';
import 'package:agrohub_app/repositories/account_repository.dart';
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
  LocalAuthService({AccountRepository? accounts})
      : _accounts = accounts ?? const SqliteAccountRepository();

  final AccountRepository _accounts;

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

  Future<LocalAccount?> validatedAccount(SessionData session) async {
    if (session.localId == null || session.token != 'LOCAL_SESSION') return null;
    final account = await _accounts.findById(session.tableName, session.localId!);
    if (account == null || !account.isActive || account.document != session.login) {
      return null;
    }
    if (session.tableName == 'operadores') {
      if (session.role != 'OPERADOR' || !session.isOperator ||
          account.ownerDocument == null) {
        return null;
      }
      for (final table in const ['fazendas', 'comercios']) {
        final owner = await _accounts.findByDocument(table, account.ownerDocument!);
        if (owner?.isActive ?? false) {
          return account;
        }
      }
      return null;
    }
    if (!session.isCompanySession ||
        session.tableName != (session.role == 'FAZENDA' ? 'fazendas' : 'comercios') ||
        session.documento != account.document ||
        !const {'ADMIN_HOME', 'OPERATOR_HOME', 'OPERATOR_LOGIN', 'ADMIN_LOGIN'}
            .contains(session.flowStage)) {
      return null;
    }
    return account;
  }

  Future<bool> isSessionValid(SessionData session) async =>
      await validatedAccount(session) != null;

  Future<LocalAccount?> authenticateAdminAccount(
      String login, String password) async {
    for (final table in const ['comercios', 'fazendas']) {
      final account = await _accounts.findByDocument(table, login);
      if (account != null && account.isActive &&
          account.adminPassword == password) {
        return account;
      }
    }
    return null;
  }

  Future<LocalAccount?> authenticateOperatorAccount(
      String login, String password) async {
    final operator = await _accounts.findByDocument('operadores', login);
    if (operator != null && operator.isActive &&
        operator.operatorPassword == password &&
        operator.ownerDocument != null) {
      for (final table in const ['fazendas', 'comercios']) {
        final owner = await _accounts.findByDocument(table, operator.ownerDocument!);
        if (owner?.isActive ?? false) {
          return operator;
        }
      }
    }
    for (final table in const ['comercios', 'fazendas']) {
      final account = await _accounts.findByDocument(table, login);
      if (account != null && account.isActive &&
          account.operationPassword == password) {
        return account;
      }
    }
    return null;
  }

  // Compatibility adapter for existing login widgets.
  static Future<LocalAuthResult?> authenticateAdmin(
      String login, String password) async {
    final account = await LocalAuthService().authenticateAdminAccount(login, password);
    return account == null ? null : _result(account);
  }

  static Future<LocalAuthResult?> authenticateOperator(
      String login, String password) async {
    final account = await LocalAuthService().authenticateOperatorAccount(login, password);
    return account == null ? null : _result(account);
  }

  static LocalAuthResult _result(LocalAccount account) => LocalAuthResult(
        role: account.table == 'operadores'
            ? 'OPERADOR' : account.table == 'fazendas' ? 'FAZENDA' : 'COMERCIO',
        tableName: account.table,
        record: {
          'id_local': account.id,
          'documento': account.document,
          'cpf': account.document,
          'documento_admin': account.ownerDocument,
          'nome': account.name,
          'nome_completo': account.name,
        },
      );
}
