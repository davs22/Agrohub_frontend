import 'dart:math' as math;
import 'package:agrohub_app/repositories/inventory_repository.dart';
import 'package:flutter/foundation.dart';

enum InventoryKind { catalog, lots, fields, operators }

class InventoryViewModel extends ChangeNotifier {
  InventoryViewModel(this.kind, {InventoryRepository? repository})
      : _repository = repository ?? const InventoryRepository();

  final InventoryKind kind;
  final InventoryRepository _repository;
  static const pageSize = 16;
  List<Map<String, dynamic>> _records = [];
  String _query = '';
  String _filter = 'all';
  int _page = 0;
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
    loading = true;
    error = null;
    _emit();
    try {
      _records = await _repository.load(table);
      canManage = await _repository.canManage();
      _page = math.min(_page, pageCount - 1);
    } catch (_) {
      error = 'Não foi possível carregar os dados. Tente novamente.';
    } finally {
      loading = false;
      _emit();
    }
  }

  List<Map<String, dynamic>> get filtered {
    final query = normalize(_query);
    return _records.where((record) {
      final status = record['status']?.toString().toUpperCase();
      if (_filter == 'active' && status != 'ATIVO') return false;
      if (_filter == 'inactive' && status != 'INATIVO') return false;
      final quantity = num.tryParse(record['quantidade'].toString()) ?? 0;
      if (_filter == 'stock' && quantity <= 0) return false;
      if (_filter == 'empty' && quantity > 0) return false;
      if (_filter == 'published' && record['is_published'].toString() != '1') {
        return false;
      }
      if (_filter == 'expired') {
        final expires =
            DateTime.tryParse(record['data_validade']?.toString() ?? '');
        final now = DateTime.now();
        if (expires == null ||
            !expires.isBefore(DateTime(now.year, now.month, now.day))) {
          return false;
        }
      }
      const fields = [
        'produto',
        'nome',
        'nome_completo',
        'talhao_nome',
        'operador_nome',
        'cultura_atual',
        'telefone',
        'email',
        'cpf',
        'status',
        'unidade_medida'
      ];
      return query.isEmpty ||
          fields.any((key) =>
              normalize(record[key]?.toString() ?? '').contains(query));
    }).toList();
  }

  int get total => filtered.length;
  int get pageCount => math.max(1, (total / pageSize).ceil());
  List<Map<String, dynamic>> get pageRecords =>
      filtered.skip(_page * pageSize).take(pageSize).toList();

  void search(String value) {
    _query = value;
    _page = 0;
    _emit();
  }

  void setFilter(String value) {
    _filter = value;
    _page = 0;
    _emit();
  }

  void goToPage(int value) {
    _page = value.clamp(0, pageCount - 1);
    _emit();
  }

  static String normalize(String value) {
    var result = value.toLowerCase().trim();
    const groups = {
      'a': 'áàâãä',
      'e': 'éèêë',
      'i': 'íìîï',
      'o': 'óòôõö',
      'u': 'úùûü',
      'c': 'ç'
    };
    groups.forEach((letter, accents) {
      for (final accent in accents.split('')) {
        result = result.replaceAll(accent, letter);
      }
    });
    return result;
  }

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
