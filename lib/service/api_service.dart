import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'auth_service.dart';
import '../models/User.dart';
import '../models/Account.dart';
import '../models/Binding.dart';
import '../models/Department.dart';
import '../models/Employee.dart';
import '../models/Job.dart';
import '../models/Revizor.dart';
import '../models/UserDepartmentBinding.dart';

class ApiService {
  final Dio _dio;
  final AuthService _authService;

  ApiService(this._dio, this._authService);

  // === USER DEPARTMENT BINDINGS ===

  Future<List<UserDepartmentBinding>> fetchUserDepartmentBindings() async {
    try {
      // debugPrint('ApiService: Fetching user-department bindings... Authenticated: ${_authService.isAuthenticated}');
      final response = await _dio.get('/user-departments');
      // debugPrint('ApiService: fetchUserDepartmentBindings - Status: ${response.statusCode}, Data type: ${response.data.runtimeType}, Data length: ${response.data is List ? (response.data as List).length : 'N/A'}');
      if (response.data is List) {
        final list = (response.data as List).map((e) => UserDepartmentBinding.fromJson(e)).toList();
        debugPrint('ApiService: Parsed ${list.length} user-department bindings.');
        return list;
      } else {
        debugPrint('ApiService: Response data is not a List: $response.data');
        return [];
      }
    } catch (e) {
      // debugPrint('ApiService: fetchUserDepartmentBindings failed: $e');
      rethrow;
    }
  }

  Future<UserDepartmentBinding> createUserDepartmentBinding({
    required int userId,
    required int departmentId,
  }) async {
    try {
      final response = await _dio.post(
        '/user-departments',
        data: {
          'user': {'id': userId},
          'department': {'id': departmentId},
        },
      );
      if (response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return UserDepartmentBinding.fromJson(response.data);
        } else {
          throw Exception('Неверный формат ответа: ожидался JSON-объект');
        }
      } else {
        throw Exception(
          'Сервер вернул статус ${response.statusCode}: ${response.data}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserDepartmentBinding> updateUserDepartmentBinding(
    int id, {
    required int userId,
    required int departmentId,
  }) async {
    try {
      final response = await _dio.put(
        '/user-departments/$id',
        data: {
          'user': {'id': userId},
          'department': {'id': departmentId},
        },
      );
      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          return UserDepartmentBinding.fromJson(response.data);
        } else {
          throw Exception('Неверный формат ответа: ожидался JSON-объект');
        }
      } else {
        throw Exception(
          'Сервер вернул статус ${response.statusCode}: ${response.data}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUserDepartmentBinding(int id) async {
    await _dio.delete('/user-departments/$id');
  }

  Future<Response> deleteUserDepartmentBindingByUser(int userId) async {
    try {
      final response = await _dio.delete('/user-departments/user/$userId');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // === USERS ===

  Future<List<User>> fetchUsers() async {
    try {
      final response = await _dio.get('/users');
      if (response.data is List) {
        return (response.data as List).map((e) => User.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      rethrow; // Перебрасываем ошибку для обработки выше
    }
  }

  Future<User> createUser(
    String username,
    String password,
    Set<String> roles, {
    int? departmentId,
  }) async {
    try {
      final data = {
        'username': username,
        'password': password,
        'roles': roles.toList(),
      };
      if (departmentId != null) {
        data['departmentId'] = departmentId;
      }
      final response = await _dio.post('/createUser', data: data);
      if (response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return User.fromJson(response.data);
        } else {
          throw Exception(
            'Неверный формат ответа: ожидался JSON-объект пользователя',
          );
        }
      } else {
        throw Exception(
          'Сервер вернул статус ${response.statusCode}: ${response.data}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateUser(
    int id,
    String username,
    Set<String> roles, {
    String? password,
  }) async {
    try {
      final data = {'username': username, 'roles': roles.toList()};
      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }
      final response = await _dio.put('/$id', data: data);
      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          return User.fromJson(response.data);
        } else {
          throw Exception('Неверный формат ответа: ожидался JSON-объект');
        }
      } else {
        throw Exception(
          'Сервер вернул статус ${response.statusCode}: ${response.data}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteUser(int id) async {
    try {
      final response = await _dio.delete('/$id');
      return response;
    } catch (e) {
      if (e is DioError) {}
      rethrow;
    }
  }

  // === BINDINGS ===
  Future<List<Binding>> fetchBindings() async {
    // debugPrint('ApiService: Fetching bindings... Authenticated: ${_authService.isAuthenticated}');
    if (!_authService.isAuthenticated) {
      // debugPrint('ApiService: fetchBindings - Not authenticated, returning empty list');
      return [];
    }
    try {
      final response = await _dio.get('/employee-departments');
      // debugPrint('ApiService: fetchBindings - Status: ${response.statusCode}, Data type: ${response.data.runtimeType}, Data length: ${response.data is List ? (response.data as List).length : 'N/A'}');
      if (response.statusCode != 200) {
        // debugPrint('ApiService: fetchBindings - Invalid status code: ${response.statusCode}');
        return [];
      }
      dynamic data = response.data;
      if (data is List) {
        final list = data.map((e) => Binding.fromJson(e)).toList();
        debugPrint('ApiService: Parsed ${list.length} bindings.');
        return list;
      } else {
        debugPrint('ApiService: Response data is not a List: $data');
        return [];
      }
    } catch (e) {
      debugPrint('ApiService: fetchBindings failed: $e');
      return [];
    }
  }

  Future<Binding> createBinding({
    required int employeeId,
    required int departmentId,
  }) async {
    final response = await _dio.post(
      '/employee-departments',
      data: {
        'employee': {'id': employeeId},
        'department': {'id': departmentId},
      },
    );
    return Binding.fromJson(response.data);
  }

  Future<Binding> updateBinding(
    int id, {
    required int employeeId,
    required int departmentId,
  }) async {
    final response = await _dio.put(
      '/employee-departments/$id',
      data: {
        'employee': {'id': employeeId},
        'department': {'id': departmentId},
      },
    );
    return Binding.fromJson(response.data);
  }

  Future<void> deleteBinding(int id) async {
    await _dio.delete('/employee-departments/$id');
  }

  // === ACCOUNTS ===
  Future<List<Account>> fetchAccounts() async {
    try {
      final response = await _dio.get('/accounts');
      if (response.data is List) {
        return (response.data as List).map((e) => Account.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
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

  // === DEPARTMENTS ===
  Future<List<Department>> fetchDepartments() async {
    if (!_authService.isAuthenticated) {
      return [];
    }
    try {
      final response = await _dio.get('/departments');
      if (response.statusCode != 200) {
        return [];
      }
      dynamic data = response.data;
      if (data is List) {
        return data.map((e) => Department.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
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
    if (!_authService.isAuthenticated) {
      return [];
    }
    try {
      final response = await _dio.get('/employees');
      if (response.statusCode != 200) {
        return [];
      }
      dynamic data = response.data;
      if (data is List) {
        return data.map((e) => Employee.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
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
    try {
      final response = await _dio.get('/revizors');
      if (response.data is List) {
        return (response.data as List).map((e) => Revizor.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
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

  // === JOBS ===
  Future<List<Job>> fetchJobs() async {
    try {
      final response = await _dio.get('/jobs');
      if (response.data is List) {
        return (response.data as List).map((e) => Job.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
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
