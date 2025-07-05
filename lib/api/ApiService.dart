import 'package:dio/dio.dart';

import '../auth/auth_service.dart';
import '../auth/user.dart';
import '../models/Account.dart';
import '../models/Binding.dart';
import '../models/Department.dart';
import '../models/Employee.dart';
import '../models/Job.dart';
import '../models/Revizor.dart';

class ApiService {
  final Dio _dio;

  ApiService(AuthService authService) : _dio = authService.dioInstance;

  // === ACCOUNTS ===
  Future<List<Account>> fetchAccounts() async {
    final response = await _dio.get('/accounts');
    return (response.data as List).map((e) => Account.fromJson(e)).toList();
  }

  Future<Account> createAccount(String name) async {
    final response = await _dio.post('/accounts', data: {'name': name});
    return Account.fromJson(response.data);
  }

  Future<Account> updateAccount(int id, String name) async {
    final response = await _dio.put('/accounts/$id', data: {'name': name});
    return Account.fromJson(response.data);
  }

  Future<void> deleteAccount(int id) async {
    await _dio.delete('/accounts/$id');
  }

  // === USERS ===
  Future<List<User>> fetchUsers() async {
    final response = await _dio.get('/users');
    return (response.data as List).map((e) => User.fromJson(e)).toList();
  }

  Future<void> createUser(String username, String password, Set<String> roles) async {
    await _dio.post('/users', data: {
      'username': username,
      'password': password,
      'roles': roles.toList(),
    });
  }

  Future<void> updateUser(int id, String username, Set<String> roles, {String? password}) async {
    final data = {
      'username': username,
      'roles': roles.toList(),
    };
    if (password != null && password.isNotEmpty) {
      data['password'] = password;
    }

    await _dio.put('/users/$id', data: data);
  }

  Future<void> deleteUser(int id) async {
    await _dio.delete('/users/$id');
  }




  // === DEPARTMENTS ===
  Future<List<Department>> fetchDepartments() async {
    final response = await _dio.get('/departments');
    return (response.data as List).map((e) => Department.fromJson(e)).toList();
  }

  Future<Department> createDepartment(String name) async {
    final response = await _dio.post('/departments', data: {'name': name});
    return Department.fromJson(response.data);
  }

  Future<Department> updateDepartment(int id, String name) async {
    final response = await _dio.put('/departments/$id', data: {'name': name});
    return Department.fromJson(response.data);
  }

  Future<void> deleteDepartment(int id) async {
    await _dio.delete('/departments/$id');
  }

  // === EMPLOYEES ===
  Future<List<Employee>> fetchEmployees() async {
    final response = await _dio.get('/employees');
    return (response.data as List).map((e) => Employee.fromJson(e)).toList();
  }

  Future<Employee> createEmployee(String name) async {
    final response = await _dio.post('/employees', data: {'name': name});
    return Employee.fromJson(response.data);
  }

  Future<Employee> updateEmployee(int id, String name) async {
    final response = await _dio.put('/employees/$id', data: {'name': name});
    return Employee.fromJson(response.data);
  }

  Future<void> deleteEmployee(int id) async {
    await _dio.delete('/employees/$id');
  }

  // === REVIZORS ===
  Future<List<Revizor>> fetchRevizors() async {
    final response = await _dio.get('/revizors');
    return (response.data as List).map((e) => Revizor.fromJson(e)).toList();
  }

  Future<Revizor> createRevizor(String name) async {
    final response = await _dio.post('/revizors', data: {'name': name});
    return Revizor.fromJson(response.data);
  }

  Future<Revizor> updateRevizor(int id, String name) async {
    final response = await _dio.put('/revizors/$id', data: {'name': name});
    return Revizor.fromJson(response.data);
  }

  Future<void> deleteRevizor(int id) async {
    await _dio.delete('/revizors/$id');
  }

  // === BINDINGS ===
  Future<List<Binding>> fetchBindings() async {
    final response = await _dio.get('/employee-departments');
    return (response.data as List).map((e) => Binding.fromJson(e)).toList();
  }

  Future<Binding> createBinding({
    required int employeeId,
    required int departmentId,
  }) async {
    final response = await _dio.post('/employee-departments', data: {
      'employee': {'id': employeeId},
      'department': {'id': departmentId},
    });
    return Binding.fromJson(response.data);
  }

  Future<Binding> updateBinding(
      int id, {
        required int employeeId,
        required int departmentId,
      }) async {
    final response = await _dio.put('/employee-departments/$id', data: {
      'employee': {'id': employeeId},
      'department': {'id': departmentId},
    });
    return Binding.fromJson(response.data);
  }

  Future<void> deleteBinding(int id) async {
    await _dio.delete('/employee-departments/$id');
  }

  // === JOBS ===
  Future<List<Job>> fetchJobs() async {
    final response = await _dio.get('/jobs');
    return (response.data as List).map((e) => Job.fromJson(e)).toList();
  }

  Future<Job> createJob(String name) async {
    final response = await _dio.post('/jobs', data: {'name': name});
    return Job.fromJson(response.data);
  }

  Future<Job> updateJob(int id, String name) async {
    final response = await _dio.put('/jobs/$id', data: {'name': name});
    return Job.fromJson(response.data);
  }

  Future<void> deleteJob(int id) async {
    await _dio.delete('/jobs/$id');
  }


}
