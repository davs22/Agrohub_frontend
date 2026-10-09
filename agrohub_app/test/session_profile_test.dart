import 'package:agrohub_app/models/profile_appearance.dart';
import 'package:agrohub_app/pages/home_adm_screen.dart';
import 'package:agrohub_app/pages/home_operador_screen.dart';
import 'package:agrohub_app/repositories/profile_repository.dart';
import 'package:agrohub_app/services/local_auth_service.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:agrohub_app/utils/flow_navigation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const admin = SessionData(
      role: 'FAZENDA',
      login: '123',
      tableName: 'fazendas',
      flowStage: 'ADMIN_HOME');
  const operator = SessionData(
      role: 'FAZENDA',
      login: '123',
      tableName: 'fazendas',
      flowStage: 'OPERATOR_HOME');
  const another = SessionData(
      role: 'FAZENDA',
      login: '456',
      tableName: 'fazendas',
      flowStage: 'ADMIN_HOME');

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Foto e avatar são isolados por papel e login', () async {
    final repository = ProfileRepository();
    await repository.saveAppearance(
        admin,
        const ProfileAppearance(
            avatarId: 'tractor', photoBase64: 'foto-admin'));
    await repository.saveAppearance(
        operator, const ProfileAppearance(avatarId: 'leaf'));
    expect((await repository.loadAppearance(admin)).photoBase64, 'foto-admin');
    expect((await repository.loadAppearance(operator)).photoBase64, isNull);
    expect((await repository.loadAppearance(operator)).avatarId, 'leaf');
    expect((await repository.loadAppearance(another)).avatarId, 'farmer');
    await repository.saveAppearance(
        admin, const ProfileAppearance(avatarId: 'farmer'));
    expect((await repository.loadAppearance(admin)).photoBase64, isNull);
    expect((await repository.loadAppearance(operator)).avatarId, 'leaf');
  });

  test('Roteamento preserva painel de administrador e de operador',
      () async {
    await SessionService.saveSession(
        role: admin.role,
        login: admin.login,
        tableName: admin.tableName,
        flowStage: admin.flowStage);
    expect(
        FlowNavigation.rootScreenForSession(admin),
        isA<HomeAdmScreen>());
    expect(FlowNavigation.rootScreenForSession(operator),
        isA<HomeOperadorScreen>());
    const conflicting = SessionData(
        role: 'OPERADOR',
        login: '1',
        tableName: 'operadores',
        flowStage: 'ADMIN_HOME');
    expect(conflicting.isAdmin, isFalse);
    expect(FlowNavigation.rootScreenForSession(conflicting),
        isA<HomeOperadorScreen>());
    await SessionService.clearSession();
    expect(await SessionService.loadSession(), isNull);
  });

  test('A segunda etapa de login aceita apenas contas da empresa selecionada',
      () {
    const selected = SessionData(
      role: 'FAZENDA',
      login: '111',
      tableName: 'fazendas',
      documento: '111',
      flowStage: 'OPERATOR_LOGIN',
    );
    const otherCompany = SessionData(
      role: 'COMERCIO',
      login: '222',
      tableName: 'comercios',
      documento: '222',
      flowStage: 'OPERATOR_LOGIN',
    );
    const ownOperator = LocalAuthResult(
      role: 'OPERADOR',
      tableName: 'operadores',
      record: {'documento_admin': '111'},
    );
    const foreignOperator = LocalAuthResult(
      role: 'OPERADOR',
      tableName: 'operadores',
      record: {'documento_admin': '222'},
    );
    const ownAdmin = LocalAuthResult(
      role: 'FAZENDA',
      tableName: 'fazendas',
      record: {'documento': '111'},
    );
    expect(LocalAuthService.belongsToCompany(ownOperator, selected), isTrue);
    expect(
        LocalAuthService.belongsToCompany(foreignOperator, selected), isFalse);
    expect(LocalAuthService.belongsToCompany(ownAdmin, selected), isTrue);
    expect(LocalAuthService.belongsToCompany(ownAdmin, otherCompany), isFalse);
  });
}
