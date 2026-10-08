import 'package:agrohub_app/entity/lote_entity.dart';
import 'package:agrohub_app/models/financial_entry.dart';
import 'package:agrohub_app/repositories/finance_repository.dart';
import 'package:agrohub_app/repositories/inventory_repository.dart';
import 'package:agrohub_app/services/local_cart_service.dart';
import 'package:agrohub_app/view_models/finance_view_model.dart';
import 'package:agrohub_app/view_models/inventory_view_model.dart';
import 'package:agrohub_app/view_models/lot_form_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryFinance extends FinanceRepository {
  MemoryFinance(this.entries);
  final List<FinancialEntry> entries;
  @override
  Future<List<FinancialEntry>> load() async => entries;
}

class MemoryInventory extends InventoryRepository {
  MemoryInventory(this.rows);
  final List<Map<String, dynamic>> rows;
  @override
  Future<List<Map<String, dynamic>>> load(String table) async => rows;
  @override
  Future<bool> canManage() async => true;
}

void main() {
  test('Valores financeiros são calculados em centavos sem erro de ponto flutuante', () {
    expect(FinancialEntry.parseCents('R\$ 1.234,56'), 123456);
    expect(FinancialEntry.parseCents('0,10'), 10);
    expect(FinancialEntry.parseCents('0,20'), 20);
    expect(FinancialEntry.parseCents('1,234'), isNull);
    expect(FinancialEntry.parseCents('-10'), isNull);
    expect(FinancialEntry.parseCents('0'), isNull);
    final summary = FinancialSummary.fromEntries([
      FinancialEntry(description: 'Venda externa', category: 'Produção', type: FinancialEntryType.income, amountCents: 10000, date: DateTime(2026, 10, 1)),
      FinancialEntry(description: 'Insumos', category: 'Produção', type: FinancialEntryType.expense, amountCents: 2500, date: DateTime(2026, 10, 2)),
    ]);
    expect(summary.balanceCents, 7500);
    expect(summary.margin, 75);
    expect(const FinancialSummary(incomeCents: 0, expenseCents: 100).margin, isNull);
  });

  test('Filtros financeiros não alteram indicadores do período e paginação cobre todos os registros', () async {
    final entries = List.generate(33, (index) => FinancialEntry(
      id: index, description: 'Receita $index', category: 'Produção', type: FinancialEntryType.income,
      amountCents: 100, date: DateTime(2026, 10, 1),
    ));
    entries.add(FinancialEntry(description: 'Anterior', category: 'Produção', type: FinancialEntryType.income, amountCents: 10000, date: DateTime(2025)));
    final model = FinanceViewModel(repository: MemoryFinance(entries), now: () => DateTime(2026, 10, 6));
    await model.load();
    expect(model.summary.incomeCents, 3300);
    expect(model.pageCount, 3);
    model.goToPage(2);
    expect(model.pageEntries.single.id, 32);
    model.setSearch('Receita 1');
    expect(model.page, 0);
    expect(model.summary.incomeCents, 3300);
    model.setPeriod(FinancePeriod.all);
    expect(model.summary.incomeCents, 13300);
    model.dispose();
  });

  test('Estoque inclui produtos sem destaque e pesquisa ignora acentos', () async {
    final rows = List.generate(33, (index) => <String, dynamic>{
      'id_local': index, 'produto': 'Maçã $index', 'quantidade': index,
      'status': 'ATIVO', 'is_published': index.isEven ? 1 : 0,
    });
    final model = InventoryViewModel(InventoryKind.catalog, repository: MemoryInventory(rows));
    await model.load();
    expect(model.total, 33);
    expect(model.pageRecords.length, 16);
    model.goToPage(2);
    expect(model.pageRecords.single['id_local'], 32);
    model.search('maca');
    expect(model.total, 33);
    expect(model.page, 0);
    model.setFilter('empty');
    expect(model.pageRecords.single['quantidade'], 0);
    model.search('não existe');
    expect(model.pageCount, 1);
    expect(model.pageRecords, isEmpty);
    model.dispose();
  });

  test('Lote preserva preço e permite remover validade', () {
    final lot = LoteEntity.fromMap({'id_local': 1, 'produto': 'Milho', 'preco_unitario': 12.50, 'quantidade': 50, 'data_validade': '2026-12-20'});
    expect(lot.toMap()['preco_unitario'], 12.50);
    expect(lot.copyWith(clearDataValidade: true).toMap()['data_validade'], isNull);
    expect(LotFormViewModel.parsePrice('12,50'), 12.50);
    expect(LotFormViewModel.parsePrice(''), 0);
    expect(LotFormViewModel.parsePrice('-1'), isNull);
    expect(LotFormViewModel.parsePrice('NaN'), isNull);
  });

  test('API legada não permite adicionar ao carrinho nem comprar', () async {
    expect(await LocalCartService.adicionarAoCarrinho(operadorId: '1', lote: {'id_local': 1}), isFalse);
    expect(await LocalCartService.finalizarCompra('1'), isFalse);
    expect(await LocalCartService.listarCarrinho('1'), isEmpty);
  });
}
