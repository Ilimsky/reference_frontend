import 'package:flutter/cupertino.dart';

import '../models/Account.dart';
import '../api/ApiService.dart';

class AccountProvider extends ChangeNotifier {
  final ApiService apiService;
  List<Account> _accounts = [];
  bool _isLoading = false;

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;

  AccountProvider(this.apiService) {
    fetchAccounts();
  }

  void fetchAccounts() async {
    _isLoading = true;
    notifyListeners();

    _accounts = await apiService.fetchAccounts();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createAccount(String name) async {
    final newAccount = await apiService.createAccount(name);
    _accounts.add(newAccount);
    notifyListeners();
  }

  Future<void> updateAccount(int id, String name) async {
    final updatedAccount = await apiService.updateAccount(id, name);
    int index = _accounts.indexWhere((account) => account.id == id);
    if (index != -1) {
      _accounts[index] = updatedAccount;
      notifyListeners();
    }
  }

  Future<void> deleteAccount(int id) async {
    await apiService.deleteAccount(id);
    _accounts.removeWhere((account) => account.id == id);
    notifyListeners();
  }
}
