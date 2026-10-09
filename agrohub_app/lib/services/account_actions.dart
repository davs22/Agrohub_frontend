import 'package:agrohub_app/models/local_account.dart';
import 'package:agrohub_app/repositories/account_repository.dart';
import 'package:agrohub_app/repositories/profile_repository.dart';
import 'package:agrohub_app/services/local_auth_service.dart';
import 'package:agrohub_app/services/session_service.dart';

class AccountActions {
  AccountActions({AccountRepository? accounts, ProfileRepository? profiles})
      : _accounts = accounts ?? const SqliteAccountRepository(),
        _profiles = profiles ?? ProfileRepository();

  final AccountRepository _accounts;
  final ProfileRepository _profiles;

  Future<(SessionData, LocalAccount)> _requireAccount(bool admin) async {
    final session = await SessionService.loadSession();
    if (session == null || (admin ? !session.isAdmin : !session.isOperator)) {
      throw StateError('Entre na conta e no perfil correspondente para continuar.');
    }
    final account = await LocalAuthService(accounts: _accounts).validatedAccount(session);
    if (account == null) {
      throw StateError('Sessão inválida. Entre novamente.');
    }
    return (session, account);
  }

  Future<LocalAccount> currentAccount({required bool admin}) async =>
      (await _requireAccount(admin)).$2;

  Future<void> changePassword({
    required bool admin,
    required String currentPassword,
    required String newPassword,
    required String confirmation,
  }) async {
    if (currentPassword.isEmpty) throw ArgumentError('Informe a senha atual.');
    if (newPassword.length < 8) throw ArgumentError('A nova senha deve ter pelo menos 8 caracteres.');
    if (newPassword != confirmation) throw ArgumentError('A confirmação não corresponde à nova senha.');
    if (newPassword == currentPassword) throw ArgumentError('Escolha uma senha diferente da atual.');
    final (_, account) = await _requireAccount(admin);
    final column = admin
        ? 'senha_adm'
        : account.table == 'operadores' ? 'senha' : 'senha_operacao';
    final changed = await _accounts.changePassword(
        account, column, currentPassword, newPassword);
    if (!changed) throw StateError('Senha atual incorreta ou conta indisponível.');
  }

  Future<void> deleteCompany({required String adminPassword}) async {
    final (session, company) = await _requireAccount(true);
    if (!company.isCompany || company.adminPassword != adminPassword) {
      throw StateError('Senha administrativa incorreta.');
    }
    final operatorDocuments = await _accounts.ownedOperatorDocuments(company);
    await _accounts.deleteCompany(company, adminPassword);
    // SQLite has committed. Invalidate the session even if profile storage fails.
    try {
      await _profiles.deleteAppearance(session);
      await _profiles.deleteAppearance(SessionData(
          role: session.role, login: session.login, tableName: session.tableName,
          flowStage: 'OPERATOR_HOME', localId: session.localId,
          documento: session.documento));
      for (final document in operatorDocuments) {
        await _profiles.deleteAppearance(SessionData(
            role: 'OPERADOR', login: document, tableName: 'operadores',
            flowStage: 'OPERATOR_HOME'));
      }
    } finally {
      await SessionService.clearSession();
    }
  }
}
