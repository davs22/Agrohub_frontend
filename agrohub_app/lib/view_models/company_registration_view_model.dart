import 'package:agrohub_app/repositories/company_registration_repository.dart';
import 'package:flutter/foundation.dart';

class CompanyRegistrationViewModel extends ChangeNotifier {
  CompanyRegistrationViewModel({CompanyRegistrationRepository? repository})
      : _repository = repository ?? const CompanyRegistrationRepository();
  final CompanyRegistrationRepository _repository;
  bool busy = false;
  String? error;
  bool _disposed = false;

  Future<bool> register(String table, Map<String, dynamic> values) async {
    if (busy) return false;
    busy = true;
    error = null;
    _notify();
    try {
      await _repository.register(table, values);
      return true;
    } catch (exception) {
      error = exception is StateError
          ? exception.message.toString()
          : 'Não foi possível cadastrar a empresa. Tente novamente.';
      return false;
    } finally {
      busy = false;
      _notify();
    }
  }
  void _notify() { if (!_disposed) notifyListeners(); }
  @override
  void dispose() { _disposed = true; super.dispose(); }
}
