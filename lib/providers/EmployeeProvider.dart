import 'package:flutter/cupertino.dart';

import '../api/ApiService.dart';
import '../models/Employee.dart';

class EmployeeProvider extends ChangeNotifier {
  final ApiService apiService;
  List<Employee> _employees = [];
  bool _isLoading = false;

  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;

  EmployeeProvider(this.apiService){
    fetchEmployees();
  }

  void fetchEmployees() async {
    _isLoading = true;
    notifyListeners();
    _employees = await apiService.fetchEmployees();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createEmployee(String name) async {
    final newEmployee = await apiService.createEmployee(name);
    _employees.add(newEmployee);
    notifyListeners();
  }

  Future<void> updateEmployee(int id, String name) async {
    final updatedEmployee = await apiService.updateEmployee(id, name);
    int index = _employees.indexWhere((employee) => employee.id == id);
    if (index != -1) {
      _employees[index] = updatedEmployee;
      notifyListeners();
    }
  }

  Future<void> deleteEmployee(int id) async {
    await apiService.deleteEmployee(id);
    _employees.removeWhere((employee) => employee.id == id);
    notifyListeners();
  }
}
