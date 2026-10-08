import 'package:agrohub_app/models/company_profile.dart';
import 'package:agrohub_app/repositories/company_repository.dart';
import 'package:flutter/foundation.dart';

class CompanyViewModel extends ChangeNotifier {
  CompanyViewModel({CompanyRepository? repository})
      : _repository = repository ?? CompanyRepository();

  final CompanyRepository _repository;
  bool saving = false;
  String? error;
  bool _disposed = false;

  Future<bool> save(CompanyProfile company, Map<String, dynamic> values) async {
    if (saving) return false;
    saving = true;
    error = null;
    notifyListeners();
    try {
      await _repository.update(company, values);
      return true;
    } catch (_) {
      error = 'Não foi possível salvar os dados. Tente novamente.';
      return false;
    } finally {
      saving = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() { _disposed = true; super.dispose(); }
}
