import 'package:agrohub_app/models/company_profile.dart';
import 'package:agrohub_app/models/financial_entry.dart';
import 'package:agrohub_app/repositories/company_repository.dart';
import 'package:agrohub_app/repositories/finance_repository.dart';
import 'package:agrohub_app/repositories/inventory_repository.dart';
import 'package:flutter/foundation.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({CompanyRepository? companies, FinanceRepository? finances, InventoryRepository? inventory})
      : _companies = companies ?? CompanyRepository(),
        _finances = finances ?? FinanceRepository(),
        _inventory = inventory ?? const InventoryRepository();

  final CompanyRepository _companies;
  final FinanceRepository _finances;
  final InventoryRepository _inventory;
  CompanyProfile? company;
  bool loading = true;
  String? error;
  int operatorCount = 0;
  int plotCount = 0;
  int lotCount = 0;
  int catalogCount = 0;
  double stockValue = 0;
  int expiringLots = 0;
  FinancialSummary summary = const FinancialSummary(incomeCents: 0, expenseCents: 0);
  bool _disposed = false;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      company = await _companies.current();
      if (company == null) {
        error = 'Acesso da empresa não encontrado. Entre novamente.';
        return;
      }
      final collections = await Future.wait([
        _inventory.load('operadores'),
        _inventory.load('talhoes'),
        _inventory.load('lotes'),
      ]);
      operatorCount = collections[0].length;
      plotCount = collections[1].length;
      final lots = collections[2];
      lotCount = lots.length;
      catalogCount = lots.where((lot) => lot['is_published'] == 1).length;
      stockValue = 0;
      expiringLots = 0;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      for (final lot in lots) {
        if (lot['status'] == 'INATIVO' || lot['status'] == 'VENDIDO') continue;
        final quantity = num.tryParse('${lot['quantidade']}') ?? 0;
        final price = num.tryParse('${lot['preco_unitario']}') ?? 0;
        stockValue += quantity * price;
        final validity = DateTime.tryParse('${lot['data_validade']}');
        if (validity != null && !validity.isBefore(today) && validity.isBefore(today.add(const Duration(days: 31)))) {
          expiringLots++;
        }
      }
      final entries = await _finances.load();
      summary = FinancialSummary.fromEntries(entries.where((entry) => entry.date.year == now.year && entry.date.month == now.month));
    } catch (_) {
      error = 'Não foi possível carregar a visão geral. Tente novamente.';
    } finally {
      loading = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() { _disposed = true; super.dispose(); }
}
