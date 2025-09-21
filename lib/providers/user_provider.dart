import 'package:flutter/material.dart';
import 'package:reference_frontend/providers/user_department_binding_provider.dart';

import '../models/User.dart';
import '../service/api_service.dart';

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
    // print('Fetching users');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _users = await apiService.fetchUsers();
      // print('Users fetched: ${_users.length} users');
    } catch (e) {
      _errorMessage = 'Failed to fetch users: $e';
      // print('Error fetching users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createUser(
    String username,
    String password,
    Set<String> roles, {
    int? departmentId,
  }) async {
    // Добавлен опциональный departmentId
    try {
      // print('Creating user: $username, roles: $roles');
      await apiService.createUser(
        username,
        password,
        roles,
        departmentId: departmentId,
      ); // Передаём departmentId
      // print('User created successfully, refreshing list...');
      await fetchUsers();
      // print('User list refreshed');
    } catch (e) {
      _errorMessage = 'Failed to create user: $e';
      // print('Error creating user: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateUser(
    int id,
    String username,
    Set<String> roles, {
    String? password,

  }) async {
    try {
      print(
        'Updating user id: $id, username: $username, roles: $roles',
      );
      await apiService.updateUser(
        id,
        username,
        roles,
        password: password,

      );
      await fetchUsers();
    } catch (e) {
      _errorMessage = 'Failed to update user: $e';
      print('Error updating user: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteUser(int id) async {
    // print('Starting deleteUser for id: $id');
    try {
      // print('Checking if user with id $id exists');
      if (!_users.any((user) => user.id == id)) {
        // print('User with id $id not found');
        throw Exception('User with id $id not found');
      }
      // print('Calling apiService.deleteUser for id: $id');
      final response = await apiService.deleteUser(id);
      // print('API deleteUser response: status=${response.statusCode}, data=${response.data}');
      // print('Removing user with id $id from local list');
      _users.removeWhere((user) => user.id == id);
      // print('Notifying listeners after user deletion');
      notifyListeners();
    } catch (e) {
      // print('Error in deleteUser: $e');
      _errorMessage = 'Failed to delete user: $e';
      notifyListeners();
      rethrow;
    }
  }
}
