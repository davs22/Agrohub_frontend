import 'dart:io';

import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/database/initial_seed_data.dart';
import 'package:agrohub_app/pages/home_adm_screen.dart';
import 'package:agrohub_app/pages/login/adm.dart';
import 'package:agrohub_app/services/local_auth_service.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:agrohub_app/theme/app_theme.dart';
import 'package:agrohub_app/view_models/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;

  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    sqflite.databaseFactory = databaseFactoryFfi;
    directory = await Directory.systemTemp.createTemp('agrohub_demo_');
    databaseFactoryFfi.setDatabasesPath(directory.path);
  });

  tearDownAll(() async {
    final database = await DatabaseHelper.instance.database;
    await database.close();
    final target = path.normalize(directory.absolute.path);
    final temporaryRoot = path.normalize(Directory.systemTemp.absolute.path);
    if (!path.isWithin(temporaryRoot, target) ||
        !path.basename(target).startsWith('agrohub_demo_')) {
      throw StateError('Diretório de teste inesperado: $target');
    }
    await directory.delete(recursive: true);
  });

  test('Base demonstrativa tem preço e financeiro sem compras fictícias',
      () async {
    final database = await DatabaseHelper.instance.database;
    expect((await database.query('fazendas')).single['documento'],
        InitialSeedData.fazendaDocumento);
    expect((await database.query('comercios')).single['documento'],
        InitialSeedData.comercioDocumento);
    final lots = await database.query('lotes');
    expect(lots, hasLength(20));
    expect(lots.every((lot) => (lot['preco_unitario'] as num) > 0), isTrue);
    expect(await database.query('carrinho_itens'), isEmpty);
    final entries = await database.query('lancamentos_financeiros');
    expect(entries, hasLength(5));
    expect(
        entries.where((entry) =>
            entry['empresa_chave'] ==
            'fazendas:${InitialSeedData.fazendaDocumento}'),
        hasLength(3));
    expect(
        entries.where((entry) =>
            entry['empresa_chave'] ==
            'comercios:${InitialSeedData.comercioDocumento}'),
        hasLength(2));
  });

  testWidgets('Login administrativo abre os dados da fazenda', (tester) async {
    final company =
        await tester.runAsync(() => LocalAuthService.authenticateOperator(
              InitialSeedData.fazendaDocumento,
              InitialSeedData.operationPassword,
            ));
    expect(company, isNotNull);
    await tester.runAsync(() => SessionService.saveSession(
          role: company!.role,
          login: InitialSeedData.fazendaDocumento,
          tableName: company.tableName,
          flowStage: 'ADMIN_LOGIN',
          localId: company.record['id_local'] as int?,
          documento: InitialSeedData.fazendaDocumento,
        ));

    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const LoginAdmScreen(),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));
    await tester.enterText(
      find.byType(TextField).at(0),
      InitialSeedData.fazendaDocumento,
    );
    await tester.enterText(
      find.byType(TextField).at(1),
      InitialSeedData.adminPassword,
    );
    await tester.runAsync(() => tester.tap(find.text('Entrar')));
    for (var attempt = 0; attempt < 5; attempt++) {
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 250)),
      );
    }
    await tester.pump();

    expect(find.byType(HomeAdmScreen), findsOneWidget);
    expect(find.text('Dados da fazenda'), findsOneWidget);
    expect(find.text('Editar'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark,
      home: const HomeAdmScreen(),
    ));
    for (var attempt = 0; attempt < 5; attempt++) {
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 250)),
      );
    }
    await tester.pump();
    expect(find.text('Dados da fazenda'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('Indicadores administrativos representam a fazenda atual', () async {
    final viewModel = DashboardViewModel();
    addTearDown(viewModel.dispose);
    await viewModel.load();
    expect(viewModel.error, isNull);
    expect(viewModel.operatorCount, 20);
    expect(viewModel.plotCount, 24);
    expect(viewModel.lotCount, 20);
    expect(viewModel.summary.incomeCents, 2700000);
    expect(viewModel.summary.expenseCents, 1220000);
  });
}
