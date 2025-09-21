import 'package:flutter/cupertino.dart';

import '../models/Department.dart';
import '../service/api_service.dart';

class DepartmentProvider extends ChangeNotifier {
  final ApiService apiService;
  List<Department> _departments = [];
  bool _isLoading = false;

  List<Department> get departments => _departments;
  bool get isLoading => _isLoading;

  DepartmentProvider(this.apiService){
    fetchDepartments();
  }

  void fetchDepartments() async {
    _isLoading = true;
    notifyListeners();
    _departments = await apiService.fetchDepartments();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createDepartment(String name) async {
    final newDepartment = await apiService.createDepartment(name);
    _departments.add(newDepartment);
    notifyListeners();
  }

  Future<void> updateDepartment(int id, String name) async {
    final updatedDepartment = await apiService.updateDepartment(id, name);
    int index = _departments.indexWhere((dept) => dept.id == id);
    if (index != -1) {
      _departments[index] = updatedDepartment;
      notifyListeners();
    }
  }

  Future<void> deleteDepartment(int id) async {
    await apiService.deleteDepartment(id);
    _departments.removeWhere((dept) => dept.id == id);
    notifyListeners();
  }
}
