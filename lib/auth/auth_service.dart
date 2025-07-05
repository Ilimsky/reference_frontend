import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthService with ChangeNotifier {
  final Dio _dio = Dio();
  String? _token;
  String? _username;
  Set<String> _roles = {};

  Dio get dioInstance => _dio;

  bool get isAuthenticated => _token != null;

  String? get username => _username;

  Set<String> get roles => _roles;

  String? get token => _token;

  AuthService() {
    // Настройка Dio
    _dio.options.baseUrl = 'http://localhost:8040/api';
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    _dio.options.headers['Content-Type'] = 'application/json';

    // Добавляем логирование интерцепторов
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    addAuthInterceptor();
  }

  Future<void> login(String username, String password) async {
    try {
      print('[AuthService] Attempting login for user: $username');

      final response = await _dio.post(
        '/login',
        data: {'username': username, 'password': password},
      );

      print('[AuthService] Login response: ${response.data}');

      _token = response.data['token'];
      _username = response.data['username'];
      _roles = Set<String>.from(response.data['roles']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('username', _username!);
      await prefs.setStringList('roles', _roles.toList());

      print('[AuthService] Login successful');
      notifyListeners();
    } on DioException catch (e) {
      print('[AuthService] Dio error during login: ${e.message}');
      print('[AuthService] Error response: ${e.response?.data}');
      throw Exception(e.response?.data?['message'] ?? 'Login failed');
    } catch (e, stackTrace) {
      print('[AuthService] Unexpected error during login: $e');
      print('[AuthService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> autoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('token');
      final savedUsername = prefs.getString('username');
      final savedRoles = prefs.getStringList('roles');

      print('[AuthService] Attempting auto-login');

      if (savedToken != null && savedUsername != null && savedRoles != null) {
        _token = savedToken;
        _username = savedUsername;
        _roles = Set<String>.from(savedRoles);

        // Проверяем валидность токена
        try {
          await _dio.get(
            '/validate',
            options: Options(headers: {'Authorization': 'Bearer $_token'}),
          );

          print('[AuthService] Auto-login successful');
          notifyListeners();
        } on DioException {
          print('[AuthService] Token validation failed');
          await logout();
        }
      } else {
        print('[AuthService] No valid credentials found');
      }
    } catch (e, stackTrace) {
      print('[AuthService] Auto-login error: $e');
      print('[AuthService] Stack trace: $stackTrace');
    }
  }

  Future<void> logout() async {
    print('[AuthService] Logging out user: $_username');

    try {
      if (_token != null) {
        await _dio.post(
          '/logout',
          options: Options(headers: {'Authorization': 'Bearer $_token'}),
        );
      }
    } catch (e) {
      print('[AuthService] Error during logout: $e');
    } finally {
      _token = null;
      _username = null;
      _roles = {};

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('username');
      await prefs.remove('roles');

      print('[AuthService] Logout completed');
      notifyListeners();
    }
  }

  bool hasRole(String role) => _roles.contains(role);

  // Добавляем токен к каждому запросу автоматически
  void addAuthInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
            print('[AuthInterceptor] Added token to request');
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            print('[AuthInterceptor] Token expired, logging out...');
            await logout();
          }
          return handler.next(error);
        },
      ),
    );
  }
}
