import 'package:agrohub_app/repositories/management_repository.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:flutter/foundation.dart';

class RecordFormViewModel extends ChangeNotifier {
  RecordFormViewModel({required this.table, this.id, ManagementRepository? repository})
      : _repository = repository ?? const ManagementRepository();

  final String table;
  final int? id;
  final ManagementRepository _repository;
  bool busy = false;
  bool ready = false;
  bool _disposed = false;
  String? error;
  Map<String, dynamic> record = {};
  List<Map<String, dynamic>> operators = [];
  Map<String, String?> errors = {};

  Future<void> load() async {
    busy = true;
    error = null;
    _notify();
    try {
      await _repository.requireAdmin();
      if (table == 'talhoes') operators = await _repository.operators();
      if (id != null) record = await _repository.find(table, id!);
      ready = true;
    } catch (exception) {
      error = _message(exception);
    } finally {
      busy = false;
      _notify();
    }
  }

  bool validate(Map<String, String> values) {
    String field(String key) => values[key]?.trim() ?? '';
    if (table == 'operadores') {
      errors = {
        'nome_completo': LoginValidators.validateRequiredText(field('nome_completo'), fieldName: 'o nome completo', minLength: 3),
        'cpf': LoginValidators.validateCpf(field('cpf')),
        'email': LoginValidators.validateEmail(field('email')),
        'telefone': LoginValidators.validatePhone(field('telefone')),
        'senha': id != null && field('senha').isEmpty ? null : LoginValidators.validatePassword(field('senha'), minLength: 8),
      };
    } else {
      errors = {
        'nome': LoginValidators.validateRequiredText(field('nome'), fieldName: 'o nome do talhão'),
        'usuario_id': field('usuario_id').isEmpty ? 'Selecione o operador responsável.' : null,
        'tamanho_hectares': LoginValidators.validatePositiveNumber(field('tamanho_hectares'), fieldName: 'a área em hectares'),
        'cultura_atual': LoginValidators.validateRequiredText(field('cultura_atual'), fieldName: 'a cultura atual'),
      };
    }
    _notify();
    return errors.values.every((error) => error == null);
  }

  Future<bool> save(Map<String, String> values, {required bool active}) async {
    if (busy || !ready || !validate(values)) return false;
    busy = true;
    error = null;
    _notify();
    try {
      final payload = <String, dynamic>{...values.map((key, value) => MapEntry(key, key == 'senha' ? value : value.trim())), 'status': active ? 'ATIVO' : 'INATIVO'};
      if (table == 'operadores') {
        payload['cpf'] = values['cpf']!.replaceAll(RegExp(r'\D'), '');
        payload['telefone'] = values['telefone']!.replaceAll(RegExp(r'\D'), '');
      } else {
        payload['tamanho_hectares'] = double.parse(values['tamanho_hectares']!.replaceAll(',', '.'));
      }
      await _repository.save(table, payload, id: id);
      return true;
    } catch (exception) {
      error = _message(exception);
      return false;
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<bool> delete() async {
    if (busy || id == null || !ready) return false;
    busy = true;
    error = null;
    _notify();
    try {
      await _repository.delete(table, id!);
      return true;
    } catch (exception) {
      error = _message(exception);
      return false;
    } finally {
      busy = false;
      _notify();
    }
  }

  String _message(Object error) => error is StateError ? error.message.toString() : 'Não foi possível salvar os dados. Tente novamente.';
  void _notify() { if (!_disposed) notifyListeners(); }
  @override
  void dispose() { _disposed = true; super.dispose(); }
}
