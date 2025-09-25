import 'package:flutter/cupertino.dart';

import '../models/UserDepartmentBinding.dart';
import '../service/api_service.dart';

class UserDepartmentBindingProvider extends ChangeNotifier {
  final ApiService apiService;
  List<UserDepartmentBinding> _bindings = [];
  bool _isLoading = false;

  List<UserDepartmentBinding> get bindings => _bindings;
  bool get isLoading => _isLoading;

  UserDepartmentBindingProvider(this.apiService);

  Future<void> fetchBindings() async {
    // print('Fetching bindings');
    _isLoading = true;
    notifyListeners();
    try {
      _bindings = await apiService.fetchUserDepartmentBindings();
      // print('Bindings fetched: ${_bindings.length} bindings');
    } catch (e) {
      // print('[ERROR] Failed to fetch user department bindings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createBinding({required int userId, required int departmentId}) async {
    try {
      // print('Creating binding for userId: $userId, departmentId: $departmentId');
      // Убрана локальная проверка на существование привязки (бэкенд обработает)
      final newBinding = await apiService.createUserDepartmentBinding(
        userId: userId,
        departmentId: departmentId,
      );
      // print('Binding created: id=${newBinding.id}');
      _bindings.add(newBinding);
      notifyListeners();
    } catch (e) {
      // print('[ERROR] Failed to create user department binding: $e');
      rethrow;
    }
  }

  Future<void> createUserWithBinding({
    required String username,
    required String password,
    required Set<String> roles,
    int? departmentId,
  }) async {
    try {
      await apiService.createUser(username, password, roles, departmentId: departmentId);
      await fetchBindings();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBinding(int id, {required int userId, required int departmentId}) async {
    try {
      print('Updating binding id: $id, userId: $userId, departmentId: $departmentId');
      final updated = await apiService.updateUserDepartmentBinding(
        id,
        userId: userId,
        departmentId: departmentId,
      );
      final index = _bindings.indexWhere((a) => a.id == id);
      if (index != -1) {
        print('Binding updated: id=$id');
        _bindings[index] = updated;
        notifyListeners();
      } else {
        print('Binding id: $id not found in local list');
        throw Exception('Binding id $id not found');
      }
    } catch (e) {
      print('[ERROR] Failed to update user department binding: $e');
      rethrow;
    }
  }

  Future<void> deleteBinding(int id) async {
    try {
      // print('Deleting binding id: $id');
      await apiService.deleteUserDepartmentBinding(id);
      // print('Binding deleted: id=$id');
      _bindings.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      // print('[ERROR] Failed to delete user department binding: $e');
      rethrow;
    }
  }

  Future<void> deleteBindingByUser(int userId) async {
    try {
      // print('Deleting bindings for userId: $userId');
      final response = await apiService.deleteUserDepartmentBindingByUser(userId);
      // print('Delete bindings response: status=${response.statusCode}, data=${response.data}');
      _bindings.removeWhere((a) => a.userId == userId);
      // print('Bindings removed locally for userId: $userId');
      notifyListeners();
    } catch (e) {
      // print('[ERROR] Failed to delete user department binding by user: $e');
      rethrow;
    }
  }
}