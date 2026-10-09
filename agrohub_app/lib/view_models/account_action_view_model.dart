import 'package:agrohub_app/models/local_account.dart';
import 'package:agrohub_app/services/account_actions.dart';
import 'package:flutter/foundation.dart';

class AccountActionViewModel extends ChangeNotifier {
  AccountActionViewModel({AccountActions? actions})
      : _actions = actions ?? AccountActions();

  final AccountActions _actions;
  bool busy = false;
  String? error;
  LocalAccount? company;

  Future<void> loadCompany() async {
    try {
      company = await _actions.currentAccount(admin: true);
      error = null;
    } catch (failure) {
      error = _message(failure);
    }
    notifyListeners();
  }

  Future<bool> changePassword({required bool admin, required String current,
      required String next, required String confirmation}) async {
    if (busy) return false;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await _actions.changePassword(admin: admin, currentPassword: current,
          newPassword: next, confirmation: confirmation);
      return true;
    } catch (failure) {
      error = _message(failure);
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCompany(String password) async {
    if (busy) return false;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await _actions.deleteCompany(adminPassword: password);
      return true;
    } catch (failure) {
      error = _message(failure);
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  String _message(Object failure) {
    if (failure is ArgumentError) return failure.message?.toString() ?? 'Dados inválidos.';
    if (failure is StateError) return failure.message;
    return 'Não foi possível concluir a operação. Tente novamente.';
  }
}
