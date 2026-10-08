import 'package:agrohub_app/repositories/inventory_repository.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:flutter/foundation.dart';

class OperatorHomeViewModel extends ChangeNotifier {
  OperatorHomeViewModel({InventoryRepository? repository})
      : _repository = repository ?? const InventoryRepository();
  final InventoryRepository _repository;
  SessionData? session;
  int fieldCount = 0;
  int lotCount = 0;
  int expiringCount = 0;
  bool loading = true;
  String? error;
  bool _disposed = false;

  Future<void> load() async {
    loading = true;
    error = null;
    _notify();
    try {
      session = await SessionService.loadSession();
      if (!(session?.isOperator ?? false)) {
        throw StateError('Entre como operador para acessar esta página.');
      }
      final fields = await _repository.load('talhoes');
      final lots = await _repository.load('lotes');
      fieldCount = fields.length;
      lotCount = lots.length;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      expiringCount = lots.where((lot) {
        final expiry = DateTime.tryParse(lot['data_validade']?.toString() ?? '');
        return expiry != null && !expiry.isBefore(today) &&
            expiry.isBefore(today.add(const Duration(days: 31))) &&
            lot['status'] != 'INATIVO' && lot['status'] != 'VENDIDO';
      }).length;
    } catch (_) {
      error = 'Não foi possível carregar os dados. Tente novamente.';
    } finally {
      loading = false;
      _notify();
    }
  }
  void _notify() { if (!_disposed) notifyListeners(); }
  @override
  void dispose() { _disposed = true; super.dispose(); }
}
