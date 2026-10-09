import 'dart:math' as math;
import 'package:agrohub_app/repositories/inventory_repository.dart';
import 'package:flutter/foundation.dart';

enum InventoryKind { catalog, lots, fields, operators }

class InventoryViewModel extends ChangeNotifier {
  InventoryViewModel(this.kind, {InventoryQueryRepository? repository})
      : _repository = repository ?? const InventoryRepository();

  final InventoryKind kind;
  final InventoryQueryRepository _repository;
  static const pageSize = 16;
  List<Map<String, dynamic>> _records = [];
  String _query = '';
  String _filter = 'all';
  int _page = 0;
  int _total = 0;
  int _generation = 0;
  bool loading = true;
  bool canManage = false;
  String? error;
  bool _disposed = false;

  String get filter => _filter;
  int get page => _page;
  String get table => switch (kind) {
        InventoryKind.operators => 'operadores',
        InventoryKind.fields => 'talhoes',
        _ => 'lotes',
      };

  Future<void> load() async {
    final generation = ++_generation;
    loading = true;
    error = null;
    _emit();
    try {
      final data = await _repository.loadPage(table,
          search: _query, filter: _filter, page: _page, pageSize: pageSize);
      final allowed = await _repository.canManage();
      if (generation != _generation) return;
      _records = data.records;
      _total = data.total;
      canManage = allowed;
      final lastPage = pageCount - 1;
      if (_page > lastPage) {
        _page = lastPage;
        await load();
        return;
      }
    } catch (_) {
      if (generation == _generation) error = 'Não foi possível carregar os dados. Tente novamente.';
    } finally {
      if (generation == _generation) {
        loading = false;
        _emit();
      }
    }
  }

  int get total => _total;
  int get pageCount => math.max(1, (_total / pageSize).ceil());
  List<Map<String, dynamic>> get pageRecords => _records;

  Future<void> search(String value) {
    _query = value;
    _page = 0;
    return load();
  }

  Future<void> setFilter(String value) {
    _filter = value;
    _page = 0;
    return load();
  }

  Future<void> goToPage(int value) {
    _page = value.clamp(0, pageCount - 1);
    return load();
  }

  static String normalize(String value) => InventoryRepository.normalize(value);

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
