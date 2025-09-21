import 'package:dio/dio.dart';

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
      final response = await _dio.get('/user-departments');
      if (response.data is List) {
        return (response.data as List)
            .map((e) => UserDepartmentBinding.fromJson(e))
            .toList();
      } else {
        // print('[WARNING] Ожидался список привязок пользователь-отдел, но получен: ${response.data.runtimeType}');
        return [];
      }
    } catch (e) {
      // print('[ERROR] Не удалось получить привязок пользователь-отдел: $e');
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
      // Проверяем успешность ответа
      if (response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return UserDepartmentBinding.fromJson(response.data);
        } else {
          print(
            '[ОШИБКА] Ожидался Map<String, dynamic>, получено: ${response.data.runtimeType}',
          );
          print('[ОШИБКА] Данные ответа: ${response.data}');
          throw Exception('Неверный формат ответа: ожидался JSON-объект');
        }
      } else {
        print(
          '[ОШИБКА] Не удалось создать привязку: Статус ${response.statusCode}, Данные: ${response.data}',
        );
        throw Exception(
          'Сервер вернул статус ${response.statusCode}: ${response.data}',
        );
      }
    } catch (e) {
      print('[ОШИБКА] Не удалось создать привязку пользователь-отдел: $e');
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
          print(
            '[ОШИБКА] Ожидался Map<String, dynamic>, получено: ${response.data.runtimeType}',
          );
          throw Exception('Неверный формат ответа: ожидался JSON-объект');
        }
      } else {
        print(
          '[ОШИБКА] Не удалось обновить привязку: Статус ${response.statusCode}, Данные: ${response.data}',
        );
        throw Exception(
          'Сервер вернул статус ${response.statusCode}: ${response.data}',
        );
      }
    } catch (e) {
      print('[ОШИБКА] Не удалось обновить привязку пользователь-отдел: $e');
      rethrow;
    }
  }

  Future<void> deleteUserDepartmentBinding(int id) async {
    await _dio.delete('/user-departments/$id');
  }

  Future<Response> deleteUserDepartmentBindingByUser(int userId) async {
    // print('API: Sending DELETE request to /user-departments/user/$userId');
    try {
      final response = await _dio.delete('/user-departments/user/$userId');
      // print('API: DELETE response: status=${response.statusCode}, data=${response.data}');
      return response;
    } catch (e) {
      // print('API: Error in deleteUserDepartmentBindingByUser: $e');
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
        // print('[WARNING] Ожидался список пользователей, но получен: ${response.data.runtimeType}');
        return []; // Возвращаем пустой список, если ответ не является списком
      }
    } catch (e) {
      // print('[ERROR] Не удалось получить пользователей: $e');
      rethrow; // Перебрасываем ошибку для обработки выше
    }
  }

  Future<User> createUser(
    String username,
    String password,
    Set<String> roles, {
    int? departmentId, // Добавлен опциональный departmentId
  }) async {
    try {
      final data = {
        'username': username,
        'password': password,
        'roles': roles.toList(),
      };
      if (departmentId != null) {
        data['departmentId'] =
            departmentId; // Добавляем departmentId в тело запроса, если указан
      }
      final response = await _dio.post('/createUser', data: data);
      if (response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return User.fromJson(response.data);
        } else {
          print(
            '[ОШИБКА] Ожидался Map<String, dynamic> для пользователя, получено: ${response.data.runtimeType}',
          );
          print('[ОШИБКА] Данные ответа: ${response.data}');
          throw Exception(
            'Неверный формат ответа: ожидался JSON-объект пользователя',
          );
        }
      } else {
        print(
          '[ОШИБКА] Не удалось создать пользователя: Статус ${response.statusCode}, Данные: ${response.data}',
        );
        throw Exception(
          'Сервер вернул статус ${response.statusCode}: ${response.data}',
        );
      }
    } catch (e) {
      print('[ОШИБКА] Не удалось создать пользователя: $e');
      rethrow;
    }
  }

  Future<User> updateUser(
    int id,
    String username,
    Set<String> roles, {
    String? password,
  }) async {
    print(
      'Sending updateUser with Authorization: ${_dio.options.headers['Authorization']}',
    );
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
          print(
            '[ОШИБКА] Ожидался Map<String, dynamic> для пользователя, получено: ${response.data.runtimeType}',
          );
          throw Exception('Неверный формат ответа: ожидался JSON-объект');
        }
      } else {
        print(
          '[ОШИБКА] Не удалось обновить пользователя: Статус ${response.statusCode}, Данные: ${response.data}',
        );
        throw Exception(
          'Сервер вернул статус ${response.statusCode}: ${response.data}',
        );
      }
    } catch (e) {
      print('[ОШИБКА] Не удалось обновить пользователя: $e');
      rethrow;
    }
  }

  Future<Response> deleteUser(int id) async {
    // print('API: Sending DELETE request to /$id');
    try {
      final response = await _dio.delete('/$id');
      // print('API: DELETE user response: status=${response.statusCode}, data=${response.data}');
      return response;
    } catch (e) {
      // print('API: Error in deleteUser: $e');
      if (e is DioError) {
        // print('DioError details: type=${e.type}, response=${e.response}, message=${e.message}');
      }
      rethrow;
    }
  }

  // === BINDINGS ===
  Future<List<Binding>> fetchBindings() async {
    if (!_authService.isAuthenticated) {
      // print('[WARNING] Не выполнен вход, запрос к /employee-departments отменен');
      return [];
    }
    try {
      final response = await _dio.get('/employee-departments');
      // print('Response status for /employee-departments: ${response.statusCode}');
      // print('Response headers for /employee-departments: ${response.headers}');
      // print('Raw response for /employee-departments: ${response.data}');
      // print('Response data type for /employee-departments: ${response.data.runtimeType}');

      if (response.statusCode != 200) {
        // print('[WARNING] Запрос к /employee-departments завершился с кодом: ${response.statusCode}');
        return [];
      }

      dynamic data = response.data;
      if (data is List) {
        return data.map((e) => Binding.fromJson(e)).toList();
      } else {
        // print('[WARNING] Ожидался список связок, но получен: ${data.runtimeType}');
        return [];
      }
    } catch (e) {
      // print('[ERROR] Не удалось получить связки: $e');
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
        // print('[WARNING] Ожидался список счетов, но получен: ${response.data.runtimeType}');
        return []; // Возвращаем пустой список, если ответ не является списком
      }
    } catch (e) {
      // print('[ERROR] Не удалось получить счета: $e');
      rethrow; // Перебрасываем ошибку для обработки выше
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
      // print('[WARNING] Не выполнен вход, запрос к /departments отменен');
      return [];
    }
    try {
      final response = await _dio.get('/departments');
      // print('Response status for /departments: ${response.statusCode}');
      // print('Response headers for /departments: ${response.headers}');
      // print('Raw response for /departments: ${response.data}');
      // print('Response data type for /departments: ${response.data.runtimeType}');

      if (response.statusCode != 200) {
        // print('[WARNING] Запрос к /departments завершился с кодом: ${response.statusCode}');
        return [];
      }

      dynamic data = response.data;
      if (data is List) {
        return data.map((e) => Department.fromJson(e)).toList();
      } else {
        // print('[WARNING] Ожидался список отделов, но получен: ${data.runtimeType}');
        return [];
      }
    } catch (e) {
      // print('[ERROR] Не удалось получить отделы: $e');
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
      // print('[WARNING] Не выполнен вход, запрос к /employees отменен');
      return [];
    }
    try {
      final response = await _dio.get('/employees');
      // print('Response status for /employees: ${response.statusCode}');
      // print('Response headers for /employees: ${response.headers}');
      // print('Raw response for /employees: ${response.data}');
      // print('Response data type for /employees: ${response.data.runtimeType}');

      if (response.statusCode != 200) {
        // print('[WARNING] Запрос к /employees завершился с кодом: ${response.statusCode}');
        return [];
      }

      dynamic data = response.data;
      if (data is List) {
        return data.map((e) => Employee.fromJson(e)).toList();
      } else {
        // print('[WARNING] Ожидался список сотрудников, но получен: ${data.runtimeType}');
        return [];
      }
    } catch (e) {
      // print('[ERROR] Не удалось получить сотрудников: $e');
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
        print(
          '[WARNING] Ожидался список ревизоров, но получен: ${response.data.runtimeType}',
        );
        return []; // Возвращаем пустой список, если ответ не является списком
      }
    } catch (e) {
      print('[ERROR] Не удалось получить ревизоров: $e');
      rethrow; // Перебрасываем ошибку для обработки выше
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
        print(
          '[WARNING] Ожидался список должностей, но получен: ${response.data.runtimeType}',
        );
        return []; // Возвращаем пустой список, если ответ не является списком
      }
    } catch (e) {
      print('[ERROR] Не удалось получить должности: $e');
      rethrow; // Перебрасываем ошибку для обработки выше
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
