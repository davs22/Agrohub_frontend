import 'dart:io';

import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/models/profile_appearance.dart';
import 'package:agrohub_app/repositories/inventory_repository.dart';
import 'package:agrohub_app/repositories/profile_repository.dart';
import 'package:agrohub_app/services/account_actions.dart';
import 'package:agrohub_app/services/local_auth_service.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  var serial = 0;

  setUpAll(() async {
    sqfliteFfiInit();
    sqflite.databaseFactory = databaseFactoryFfi;
    directory = await Directory.systemTemp.createTemp('agrohub_regression_');
    databaseFactoryFfi.setDatabasesPath(directory.path);
  });

  tearDownAll(() async {
    await (await DatabaseHelper.instance.database).close();
    final target = path.normalize(directory.absolute.path);
    final root = path.normalize(Directory.systemTemp.absolute.path);
    if (!path.isWithin(root, target) ||
        !path.basename(target).startsWith('agrohub_regression_')) {
      throw StateError('Diretório de teste inesperado: $target');
    }
    await directory.delete(recursive: true);
  });

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<({String document, int id, int operatorId, int fieldId, int lotId})>
      company({String status = 'ATIVO'}) async {
    final number = ++serial;
    final document = '99000${number.toString().padLeft(9, '0')}';
    final helper = DatabaseHelper.instance;
    final id = await helper.inserirRegistro('fazendas', {
      'nome': 'Empresa $number', 'documento': document, 'hectares': 10,
      'senha_adm': 'Admin1234', 'senha_operacao': 'Campo1234', 'status': status,
    });
    final operatorId = await helper.inserirRegistro('operadores', {
      'documento_admin': document, 'nome_completo': 'Operador $number',
      'cpf': '88000${number.toString().padLeft(6, '0')}',
      'senha': 'Operator1234', 'status': 'ATIVO',
    });
    final fieldId = await helper.inserirRegistro('talhoes', {
      'usuario_id': '$operatorId', 'nome': 'Talhão $number',
      'tamanho_hectares': 10, 'cultura_atual': 'Café', 'status': 'ATIVO',
    });
    final lotId = await helper.inserirRegistro('lotes', {
      'usuario_id': '$operatorId', 'operador_id': '$operatorId',
      'talhao_id': '$fieldId', 'produto': 'Maçã $number',
      'quantidade': 10, 'unidade_medida': 'caixa', 'status': 'ATIVO',
    });
    return (document: document, id: id, operatorId: operatorId,
        fieldId: fieldId, lotId: lotId);
  }

  Future<void> adminSession(({String document, int id, int operatorId,
      int fieldId, int lotId}) value) => SessionService.saveSession(
        role: 'FAZENDA', login: value.document, tableName: 'fazendas',
        flowStage: 'ADMIN_HOME', localId: value.id, documento: value.document);

  test('Senha atual incorreta e sessão adulterada não alteram outra conta', () async {
    final first = await company();
    final second = await company();
    await adminSession(first);
    final actions = AccountActions();
    await expectLater(actions.changePassword(admin: true,
        currentPassword: 'errada', newPassword: 'Nova12345',
        confirmation: 'Nova12345'), throwsStateError);
    expect((await DatabaseHelper.instance.buscarPorId('fazendas', first.id))?['senha_adm'], 'Admin1234');
    await SessionService.saveSession(role: 'FAZENDA', login: first.document,
        tableName: 'fazendas', flowStage: 'ADMIN_HOME', localId: second.id,
        documento: first.document);
    await expectLater(actions.changePassword(admin: true,
        currentPassword: 'Admin1234', newPassword: 'Nova12345',
        confirmation: 'Nova12345'), throwsStateError);
    expect((await DatabaseHelper.instance.buscarPorId('fazendas', second.id))?['senha_adm'], 'Admin1234');
  });

  test('Alteração válida modifica só a senha do perfil autenticado', () async {
    final target = await company();
    await adminSession(target);
    final actions = AccountActions();
    await expectLater(actions.changePassword(admin: false,
        currentPassword: 'Campo1234', newPassword: 'Nova12345',
        confirmation: 'Nova12345'), throwsStateError);
    await actions.changePassword(admin: true, currentPassword: 'Admin1234',
        newPassword: 'Nova12345', confirmation: 'Nova12345');
    final account = await DatabaseHelper.instance.buscarPorId('fazendas', target.id);
    expect(account?['senha_adm'], 'Nova12345');
    expect(account?['senha_operacao'], 'Campo1234');
    expect(await LocalAuthService.authenticateAdmin(target.document, 'Admin1234'), isNull);
    expect(await LocalAuthService.authenticateAdmin(target.document, 'Nova12345'), isNotNull);
  });

  test('Contas e empresa inativas bloqueiam login e sessão persistida', () async {
    final inactive = await company(status: 'INATIVO');
    final active = await company();
    final helper = DatabaseHelper.instance;
    expect(await LocalAuthService.authenticateAdmin(inactive.document, 'Admin1234'), isNull);
    final operator = await helper.buscarPorId('operadores', inactive.operatorId);
    expect(await LocalAuthService.authenticateOperator(operator!['cpf'].toString(), 'Operator1234'), isNull);
    final activeOperator = await helper.buscarPorId('operadores', active.operatorId);
    await helper.atualizarRegistro('operadores', {'status': 'INATIVO'}, active.operatorId);
    expect(await LocalAuthService.authenticateOperator(activeOperator!['cpf'].toString(), 'Operator1234'), isNull);
    await helper.atualizarRegistro('operadores', {'status': 'ATIVO'}, active.operatorId);
    await SessionService.saveSession(role: 'OPERADOR', login: activeOperator['cpf'].toString(),
        tableName: 'operadores', flowStage: 'OPERATOR_HOME', localId: active.operatorId);
    expect(await SessionService.loadSession(), isNotNull);
    await helper.atualizarRegistro('operadores', {'status': 'INATIVO'}, active.operatorId);
    expect(await SessionService.loadSession(), isNull);
    await adminSession(inactive);
    expect(await SessionService.loadSession(), isNull);
    await adminSession(active);
    await helper.atualizarRegistro('fazendas', {'status': 'INATIVO'}, active.id);
    expect(await SessionService.loadSession(), isNull);
    await helper.deletarRegistro('fazendas', active.id);
    await SessionService.saveSession(role: 'FAZENDA', login: active.document,
        tableName: 'fazendas', flowStage: 'ADMIN_HOME', localId: active.id,
        documento: active.document);
    expect(await SessionService.loadSession(), isNull);
  });

  test('Exclusão é restrita à empresa da sessão e preserva a outra', () async {
    final first = await company();
    final second = await company();
    final helper = DatabaseHelper.instance;
    await helper.inserirRegistro('lancamentos_financeiros', {
      'empresa_chave': 'fazendas:${first.document}', 'descricao': 'Receita',
      'categoria': 'Venda', 'tipo': 'RECEITA', 'valor_centavos': 100,
      'data_movimento': DateTime.now().toIso8601String(),
    });
    final firstCartId = await helper.inserirRegistro('carrinho_itens', {
      'operador_id': '${first.operatorId}', 'lote_id': '${first.lotId}',
      'produto': 'Maçã', 'quantidade': 1, 'status': 'ATIVO',
    });
    final secondCartId = await helper.inserirRegistro('carrinho_itens', {
      'operador_id': '${second.operatorId}', 'lote_id': '${second.lotId}',
      'produto': 'Maçã', 'quantidade': 1, 'status': 'ATIVO',
    });
    await adminSession(first);
    final admin = (await SessionService.loadSession())!;
    final operatorDocument = (await helper.buscarPorId('operadores', first.operatorId))!['cpf'].toString();
    final operatorSession = SessionData(role: 'OPERADOR', login: operatorDocument,
        tableName: 'operadores', flowStage: 'OPERATOR_HOME');
    final profiles = ProfileRepository();
    await profiles.saveAppearance(admin, const ProfileAppearance(avatarId: 'tractor'));
    await profiles.saveAppearance(operatorSession, const ProfileAppearance(avatarId: 'leaf'));
    await expectLater(AccountActions().deleteCompany(adminPassword: 'incorreta'), throwsStateError);
    expect(await helper.buscarPorId('fazendas', first.id), isNotNull);
    await AccountActions().deleteCompany(adminPassword: 'Admin1234');
    expect(await SessionService.loadSession(), isNull);
    expect((await profiles.loadAppearance(admin)).avatarId, 'farmer');
    expect((await profiles.loadAppearance(operatorSession)).avatarId, 'farmer');
    expect(await helper.buscarPorId('fazendas', first.id), isNull);
    expect(await helper.buscarPorId('operadores', first.operatorId), isNull);
    expect(await helper.buscarPorId('talhoes', first.fieldId), isNull);
    expect(await helper.buscarPorId('lotes', first.lotId), isNull);
    expect(await helper.buscarPorId('carrinho_itens', firstCartId), isNull);
    expect(await helper.listarComFiltro('lancamentos_financeiros',
        where: 'empresa_chave = ?', whereArgs: ['fazendas:${first.document}']), isEmpty);
    expect(await helper.buscarPorId('fazendas', second.id), isNotNull);
    expect(await helper.buscarPorId('operadores', second.operatorId), isNotNull);
    expect(await helper.buscarPorId('talhoes', second.fieldId), isNotNull);
    expect(await helper.buscarPorId('lotes', second.lotId), isNotNull);
    expect(await helper.buscarPorId('carrinho_itens', secondCartId), isNotNull);
  });

  test('Falha durante a transação reverte todos os registros', () async {
    final target = await company();
    await adminSession(target);
    final db = await DatabaseHelper.instance.database;
    await db.execute("CREATE TRIGGER stop_delete BEFORE DELETE ON fazendas WHEN OLD.id_local = ${target.id} BEGIN SELECT RAISE(ABORT, 'fail'); END");
    try {
      await expectLater(AccountActions().deleteCompany(adminPassword: 'Admin1234'), throwsA(isA<Exception>()));
      expect(await DatabaseHelper.instance.buscarPorId('fazendas', target.id), isNotNull);
      expect(await DatabaseHelper.instance.buscarPorId('operadores', target.operatorId), isNotNull);
      expect(await DatabaseHelper.instance.buscarPorId('talhoes', target.fieldId), isNotNull);
      expect(await DatabaseHelper.instance.buscarPorId('lotes', target.lotId), isNotNull);
    } finally {
      await db.execute('DROP TRIGGER stop_delete');
    }
  });

  test('Vínculo contraditório entre empresas impede exclusão parcial', () async {
    final first = await company();
    final second = await company();
    final helper = DatabaseHelper.instance;
    final mixedLotId = await helper.inserirRegistro('lotes', {
      'usuario_id': '${first.operatorId}', 'operador_id': '${first.operatorId}',
      'talhao_id': '${second.fieldId}', 'produto': 'Lote inconsistente',
      'quantidade': 1, 'unidade_medida': 'caixa', 'status': 'ATIVO',
    });
    await adminSession(first);
    await expectLater(AccountActions().deleteCompany(adminPassword: 'Admin1234'), throwsStateError);
    expect(await helper.buscarPorId('fazendas', first.id), isNotNull);
    expect(await helper.buscarPorId('operadores', first.operatorId), isNotNull);
    expect(await helper.buscarPorId('lotes', mixedLotId), isNotNull);
    expect(await helper.buscarPorId('fazendas', second.id), isNotNull);
  });

  test('Consulta SQL aplica empresa, pesquisa sem acentos, filtro e página', () async {
    final first = await company();
    final second = await company();
    final helper = DatabaseHelper.instance;
    for (var index = 0; index < 20; index++) {
      await helper.inserirRegistro('lotes', {
        'usuario_id': '${first.operatorId}', 'operador_id': '${first.operatorId}',
        'talhao_id': '${first.fieldId}', 'produto': 'Café $index',
        'quantidade': index, 'unidade_medida': 'saca', 'status': 'ATIVO',
      });
    }
    await adminSession(first);
    const repository = InventoryRepository();
    final page0 = await repository.loadPage('lotes', search: 'cafe', pageSize: 16);
    final page1 = await repository.loadPage('lotes', search: 'cafe', page: 1, pageSize: 16);
    expect(page0.total, 20);
    expect(page0.records, hasLength(16));
    expect(page1.total, 20);
    expect(page1.records, hasLength(4));
    expect(page1.records.map((row) => row['id_local']).toSet()
        .intersection(page0.records.map((row) => row['id_local']).toSet()), isEmpty);
    final empty = await repository.loadPage('lotes', search: 'cafe', filter: 'empty');
    expect(empty.total, 1);
    expect(empty.records.single['quantidade'], 0);
    expect((await repository.loadPage('lotes', search: 'maca')).total, 1);
    await adminSession(second);
    expect((await repository.loadPage('lotes', search: 'cafe')).total, 0);
  });
}
