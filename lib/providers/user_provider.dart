import 'package:flutter/material.dart';

import '../api/ApiService.dart';
import '../auth/user.dart';

class UserProvider extends ChangeNotifier {
  final ApiService apiService;

  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UserProvider(this.apiService) {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _users = await apiService.fetchUsers();
    } catch (e) {
      _errorMessage = 'Failed to fetch users';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createUser(String username, String password, Set<String> roles) async {
    try {
      await apiService.createUser(username, password, roles);
      await fetchUsers();
    } catch (e) {
      _errorMessage = 'Failed to create user';
      notifyListeners();
    }
  }

  Future<void> updateUser(int id, String username, Set<String> roles, {String? password}) async {
    try {
      await apiService.updateUser(id, username, roles, password: password);
      await fetchUsers();
    } catch (e) {
      _errorMessage = 'Failed to update user';
      notifyListeners();
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await apiService.deleteUser(id);
      _users.removeWhere((user) => user.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete user';
      notifyListeners();
    }
  }
}
