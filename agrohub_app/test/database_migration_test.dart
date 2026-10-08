import 'dart:io';

import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/models/financial_entry.dart';
import 'package:agrohub_app/repositories/finance_repository.dart';
import 'package:agrohub_app/repositories/inventory_repository.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;

  setUpAll(() async {
    sqfliteFfiInit();
    sqflite.databaseFactory = databaseFactoryFfi;
    directory = await Directory.systemTemp.createTemp('agrohub_migration_');
    databaseFactoryFfi.setDatabasesPath(directory.path);
    final legacy = await sqflite.openDatabase(
      path.join(directory.path, 'agrohub_offline.db'),
      version: 4,
      onCreate: (database, _) async {
        await database.execute('CREATE TABLE fazendas (id_local INTEGER PRIMARY KEY, documento TEXT, nome TEXT)');
        await database.execute('CREATE TABLE comercios (id_local INTEGER PRIMARY KEY, documento TEXT, nome TEXT)');
        await database.execute('CREATE TABLE operadores (id_local INTEGER PRIMARY KEY, documento_admin TEXT, nome_completo TEXT)');
        await database.execute('CREATE TABLE talhoes (id_local INTEGER PRIMARY KEY, usuario_id TEXT, nome TEXT)');
        await database.execute('CREATE TABLE lotes (id_local INTEGER PRIMARY KEY, produto TEXT, quantidade INTEGER, operador_id TEXT, talhao_id TEXT, status TEXT, is_published INTEGER)');
        await database.insert('fazendas', {'id_local': 1, 'documento': '111', 'nome': 'Fazenda Um'});
        await database.insert('comercios', {'id_local': 1, 'documento': '222', 'nome': 'Comércio Dois'});
        await database.insert('operadores', {'id_local': 1, 'documento_admin': '111', 'nome_completo': 'Ana'});
        await database.insert('operadores', {'id_local': 2, 'documento_admin': '222', 'nome_completo': 'Beto'});
        await database.insert('talhoes', {'id_local': 1, 'usuario_id': '1', 'nome': 'Campo A'});
        await database.insert('talhoes', {'id_local': 2, 'usuario_id': '2', 'nome': 'Campo B'});
        await database.insert('lotes', {'id_local': 1, 'produto': 'Tomate', 'quantidade': 10, 'operador_id': '1', 'talhao_id': '1', 'status': 'ATIVO', 'is_published': 1});
        await database.insert('lotes', {'id_local': 2, 'produto': 'Milho', 'quantidade': 20, 'operador_id': '2', 'talhao_id': '2', 'status': 'ATIVO', 'is_published': 0});
      },
    );
    await legacy.close();
    SharedPreferences.setMockInitialValues({});
  });

  tearDownAll(() async {
    final db = await DatabaseHelper.instance.database;
    await db.close();
    final target = path.normalize(directory.absolute.path);
    final temporaryRoot = path.normalize(Directory.systemTemp.absolute.path);
    if (!path.isWithin(temporaryRoot, target) ||
        !path.basename(target).startsWith('agrohub_migration_')) {
      throw StateError('Diretório de teste inesperado: $target');
    }
    await directory.delete(recursive: true);
  });

  test('Migração mantém dados e separa estoque e lançamentos por empresa', () async {
    final db = await DatabaseHelper.instance.database;
    expect(await db.getVersion(), 5);
    final existing = await DatabaseHelper.instance.buscarPorId('lotes', 1);
    expect(existing?['produto'], 'Tomate');
    expect(existing?['preco_unitario'], 0);
    expect(existing?['data_validade'], isNull);
    await SessionService.saveSession(role: 'FAZENDA', login: '111', tableName: 'fazendas', flowStage: 'ADMIN_HOME', localId: 1, documento: '111');
    final farmInventory = await const InventoryRepository().load('lotes');
    expect(farmInventory.map((lot) => lot['produto']), ['Tomate']);
    final finance = FinanceRepository();
    await finance.save(FinancialEntry(description: 'Receita registrada', category: 'Colheita', type: FinancialEntryType.income, amountCents: 25000, date: DateTime(2026, 10, 6)));
    expect((await finance.load()).single.amountCents, 25000);
    await SessionService.saveSession(role: 'COMERCIO', login: '222', tableName: 'comercios', flowStage: 'ADMIN_HOME', localId: 1, documento: '222');
    final storeInventory = await const InventoryRepository().load('lotes');
    expect(storeInventory.map((lot) => lot['produto']), ['Milho']);
    expect(await finance.load(), isEmpty);
    await SessionService.saveSession(role: 'OPERADOR', login: '1', tableName: 'operadores', flowStage: 'OPERATOR_HOME', localId: 1);
    expect(await const InventoryRepository().canManage(), isFalse);
    expect(() async => await finance.save(FinancialEntry(description: 'Impróprio', category: 'Teste', type: FinancialEntryType.expense, amountCents: 100, date: DateTime.now())), throwsStateError);
  });
}
