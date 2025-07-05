import 'package:flutter/material.dart';
import '../api/ApiService.dart';
import '../models/Binding.dart';

class BindingProvider extends ChangeNotifier {
  final ApiService apiService;
  List<Binding> _bindings = [];
  bool _isLoading = false;

  List<Binding> get bindings => _bindings;
  bool get isLoading => _isLoading;

  BindingProvider(this.apiService);

  Future<void> fetchBindings() async {
    _isLoading = true;
    notifyListeners();
    try {
      _bindings = await apiService.fetchBindings();
    } catch (e) {
      print('[ERROR] Failed to fetch bindings: \$e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createBinding({required int employeeId, required int departmentId}) async {
    try {
      final newBinding = await apiService.createBinding(
        employeeId: employeeId,
        departmentId: departmentId,
      );
      _bindings.add(newBinding);
      notifyListeners();
    } catch (e) {
      print('[ERROR] Failed to create binding: \$e');
    }
  }

  Future<void> updateBinding(int id, {required int employeeId, required int departmentId}) async {
    try {
      final updated = await apiService.updateBinding(
        id,
        employeeId: employeeId,
        departmentId: departmentId,
      );
      final index = _bindings.indexWhere((a) => a.id == id);
      if (index != -1) {
        _bindings[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      print('[ERROR] Failed to update binding: \$e');
    }
  }

  Future<void> deleteBinding(int id) async {
    try {
      await apiService.deleteBinding(id);
      _bindings.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      print('[ERROR] Failed to delete binding: \$e');
    }
  }
}