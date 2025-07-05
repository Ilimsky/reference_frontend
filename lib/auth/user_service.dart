import 'package:flutter/material.dart';
import 'package:reference_frontend/auth/user.dart';
import 'auth_service.dart';

import 'package:dio/dio.dart';

class UserService with ChangeNotifier {
  final AuthService _authService;
  final List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UserService(this._authService);

  Future<void> fetchUsers() async {
    try {
      _startLoading();
      _clearError();

      final response = await _authService.dioInstance.get('/users');

      final List<dynamic> data = response.data;
      _users.clear();
      _users.addAll(data.map((json) => User.fromJson(json)));

    } on DioException catch (e) {
      _handleDioError(e, 'Failed to fetch users');
    } catch (e) {
      _handleGenericError(e, 'Failed to fetch users');
    } finally {
      _stopLoading();
    }
  }

  Future<void> createUser({
    required String username,
    required String password,
    required Set<String> roles,
  }) async {
    try {
      _startLoading();
      _clearError();

      await _authService.dioInstance.post(
        '/users',
        data: {
          'username': username,
          'password': password,
          'roles': roles.toList(),
        },
      );

      await fetchUsers();
    } on DioException catch (e) {
      _handleDioError(e, 'Failed to create user');
    } catch (e) {
      _handleGenericError(e, 'Failed to create user');
    } finally {
      _stopLoading();
    }
  }

  Future<void> updateUser({
    required int id,
    required String username,
    String? password,
    required Set<String> roles,
  }) async {
    try {
      _startLoading();
      _clearError();

      final data = {
        'username': username,
        'roles': roles.toList(),
      };

      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }

      await _authService.dioInstance.put(
        '/users/$id',
        data: data,
      );

      await fetchUsers();
    } on DioException catch (e) {
      _handleDioError(e, 'Failed to update user');
    } catch (e) {
      _handleGenericError(e, 'Failed to update user');
    } finally {
      _stopLoading();
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      _startLoading();
      _clearError();

      await _authService.dioInstance.delete('/users/$id');

      _users.removeWhere((user) => user.id == id);
      notifyListeners();
    } on DioException catch (e) {
      _handleDioError(e, 'Failed to delete user');
    } catch (e) {
      _handleGenericError(e, 'Failed to delete user');
    } finally {
      _stopLoading();
    }
  }

  // Вспомогательные методы
  void _startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _handleDioError(DioException e, String defaultMessage) {
    final response = e.response;
    final errorData = response?.data;
    _errorMessage = errorData?['message'] ?? defaultMessage;
    notifyListeners();
  }

  void _handleGenericError(Object e, String defaultMessage) {
    _errorMessage = defaultMessage;
    notifyListeners();
  }
}