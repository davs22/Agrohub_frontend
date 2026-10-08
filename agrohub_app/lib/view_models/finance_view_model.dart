import 'package:agrohub_app/models/financial_entry.dart';
import 'package:agrohub_app/repositories/finance_repository.dart';
import 'package:flutter/foundation.dart';

enum FinancePeriod { month, year, all }

class FinanceViewModel extends ChangeNotifier {
  FinanceViewModel({FinanceRepository? repository, DateTime Function()? now})
      : _repository = repository ?? FinanceRepository(), _now = now ?? DateTime.now;

  final FinanceRepository _repository;
  final DateTime Function() _now;
  List<FinancialEntry> _entries = [];
  bool loading = true;
  bool saving = false;
  String? error;
  FinancePeriod period = FinancePeriod.month;
  String search = '';
  FinancialEntryType? type;
  int page = 0;
  static const pageSize = 16;
  int get pageCount => (visibleEntries.length / pageSize).ceil().clamp(1, 1000000);
  List<FinancialEntry> get pageEntries => visibleEntries.skip(page * pageSize).take(pageSize).toList();
  bool _disposed = false;

  List<FinancialEntry> get periodEntries {
    final now = _now();
    return _entries.where((entry) => switch (period) {
      FinancePeriod.month => entry.date.year == now.year && entry.date.month == now.month,
      FinancePeriod.year => entry.date.year == now.year,
      FinancePeriod.all => true,
    }).toList();
  }

  List<FinancialEntry> get visibleEntries => periodEntries.where((entry) {
    final text = '${entry.description} ${entry.category}'.toLowerCase();
    return (type == null || entry.type == type) && text.contains(search.trim().toLowerCase());
  }).toList();

  FinancialSummary get summary => FinancialSummary.fromEntries(periodEntries);

  void setPeriod(FinancePeriod value) { period = value; page = 0; notifyListeners(); }
  void setSearch(String value) { search = value; page = 0; notifyListeners(); }
  void setType(FinancialEntryType? value) { type = value; page = 0; notifyListeners(); }
  void goToPage(int value) { page = value.clamp(0, pageCount - 1); notifyListeners(); }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try { _entries = await _repository.load(); page = page.clamp(0, pageCount - 1); }
    catch (_) { error = 'Não foi possível carregar os lançamentos. Tente novamente.'; }
    finally { loading = false; if (!_disposed) notifyListeners(); }
  }

  Future<bool> save(FinancialEntry entry) => _mutate(() => _repository.save(entry));
  Future<bool> delete(int id) => _mutate(() => _repository.delete(id));

  Future<bool> _mutate(Future<void> Function() action) async {
    if (saving) return false;
    saving = true;
    error = null;
    notifyListeners();
    try {
      await action();
      _entries = await _repository.load();
      page = page.clamp(0, pageCount - 1);
      return true;
    } catch (_) {
      error = 'Não foi possível salvar a alteração. Tente novamente.';
      return false;
    } finally {
      saving = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() { _disposed = true; super.dispose(); }
}
