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
    debugPrint(
      '[AuthService] [${DateTime.now().toIso8601String()}] Initializing AuthService...',
    );
    // _dio.options.baseUrl = 'http://localhost:8040/api';
    _dio.options.baseUrl = 'https://reference-hbik.onrender.com/api';
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.responseType = ResponseType.json; // Добавляем
    _dio.options.validateStatus = (status) {
      debugPrint(
        '[AuthService] [${DateTime.now().toIso8601String()}] Validating status: $status',
      );
      return status! < 500;
    };
    debugPrint(
      '[AuthService] [${DateTime.now().toIso8601String()}] Dio configured with baseUrl: ${_dio.options.baseUrl}',
    );

    // Добавляем логирование интерцепторов
    // _dio.interceptors.add(
    //   LogInterceptor(
    //     request: false,
    //     requestBody: false,
    //     responseBody: false,
    //     error: false,
    //   ),
    // );

    addAuthInterceptor();
    debugPrint(
      '[AuthService] [${DateTime.now().toIso8601String()}] AuthInterceptor added',
    );
  }

  Future<void> login(String username, String password) async {
    final startTime = DateTime.now();
    debugPrint(
      '[AuthService] [${startTime.toIso8601String()}] Starting login for username: $username',
    );
    try {
      final response = await _dio.post(
        '/login',
        data: {'username': username, 'password': password},
      );
      debugPrint(
        '[AuthService] [${DateTime.now().toIso8601String()}] Login request completed, status: ${response.statusCode}, duration: ${DateTime.now().difference(startTime).inMilliseconds}ms',
      );

      _token = response.data['token'];
      _username = response.data['username'];
      _roles = Set<String>.from(response.data['roles']);
      debugPrint(
        '[AuthService] [${DateTime.now().toIso8601String()}] Login successful, token: ${_token?.substring(0, 10)}..., username: $_username, roles: $_roles',
      );

      final prefsStart = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('username', _username!);
      await prefs.setStringList('roles', _roles.toList());
      debugPrint(
        '[AuthService] [${DateTime.now().toIso8601String()}] Saved to SharedPreferences, duration: ${DateTime.now().difference(prefsStart).inMilliseconds}ms',
      );

      notifyListeners();
      debugPrint(
        '[AuthService] [${DateTime.now().toIso8601String()}] Listeners notified',
      );
    } on DioException catch (e) {
      debugPrint(
        '[AuthService] [${DateTime.now().toIso8601String()}] Login failed with DioException: ${e.message}, status: ${e.response?.statusCode}, response: ${e.response?.data}, duration: ${DateTime.now().difference(startTime).inMilliseconds}ms',
      );
      throw Exception(e.response?.data?['message'] ?? 'Login failed');
    } catch (e, stackTrace) {
      debugPrint(
        '[AuthService] [${DateTime.now().toIso8601String()}] Unexpected error in login: $e, StackTrace: $stackTrace, duration: ${DateTime.now().difference(startTime).inMilliseconds}ms',
      );
      rethrow;
    }
  }

  Future<void> autoLogin() async {
    final startTime = DateTime.now();
    debugPrint('[AuthService] [${startTime.toIso8601String()}] Starting autoLogin');
    try {
      final prefsStart = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('token');
      final savedUsername = prefs.getString('username');
      final savedRoles = prefs.getStringList('roles');
      debugPrint('[AuthService] [${DateTime.now().toIso8601String()}] Loaded from SharedPreferences: token=${savedToken?.substring(0, 10)}..., username=$savedUsername, roles=$savedRoles, duration: ${DateTime.now().difference(prefsStart).inMilliseconds}ms');

      if (savedToken != null && savedUsername != null && savedRoles != null) {
        _token = savedToken;
        _username = savedUsername;
        _roles = Set<String>.from(savedRoles);
        debugPrint('[AuthService] [${DateTime.now().toIso8601String()}] Set token, username, roles; isAuthenticated: $isAuthenticated');
        notifyListeners();
        debugPrint('[AuthService] [${DateTime.now().toIso8601String()}] Listeners notified');
      } else {
        debugPrint('[AuthService] [${DateTime.now().toIso8601String()}] No saved credentials found in SharedPreferences');
      }
    } catch (e, stackTrace) {
      debugPrint('[AuthService] [${DateTime.now().toIso8601String()}] autoLogin failed: $e, StackTrace: $stackTrace, duration: ${DateTime.now().difference(startTime).inMilliseconds}ms');
    }
    debugPrint('[AuthService] [${DateTime.now().toIso8601String()}] autoLogin completed, isAuthenticated: $isAuthenticated, duration: ${DateTime.now().difference(startTime).inMilliseconds}ms');
  }

  Future<void> logout() async {
    final startTime = DateTime.now();
    debugPrint(
      '[AuthService] [${startTime.toIso8601String()}] Starting logout',
    );
    try {
      if (_token != null) {
        final logoutStart = DateTime.now();
        final response = await _dio.post(
          '/logout',
          options: Options(headers: {'Authorization': 'Bearer $_token'}),
        );
        debugPrint(
          '[AuthService] [${DateTime.now().toIso8601String()}] Logout request completed, status: ${response.statusCode}, response: ${response.data}, duration: ${DateTime.now().difference(logoutStart).inMilliseconds}ms',
        );
      } else {
        debugPrint(
          '[AuthService] [${DateTime.now().toIso8601String()}] No token found, skipping logout request',
        );
      }
    } catch (e) {
      debugPrint(
        '[AuthService] [${DateTime.now().toIso8601String()}] Logout request failed: $e',
      );
    } finally {
      final clearStart = DateTime.now();
      _token = null;
      _username = null;
      _roles = {};
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('username');
      await prefs.remove('roles');
      debugPrint(
        '[AuthService] [${DateTime.now().toIso8601String()}] Cleared credentials from SharedPreferences, duration: ${DateTime.now().difference(clearStart).inMilliseconds}ms',
      );
      notifyListeners();
      debugPrint(
        '[AuthService] [${DateTime.now().toIso8601String()}] Listeners notified after logout, duration: ${DateTime.now().difference(startTime).inMilliseconds}ms',
      );
    }
  }

  bool hasRole(String role) => _roles.contains(role);

  void addAuthInterceptor() {
    debugPrint(
      '[AuthService] [${DateTime.now().toIso8601String()}] Adding AuthInterceptor',
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint(
            '[AuthService] [${DateTime.now().toIso8601String()}] onRequest: Adding Authorization header for ${options.uri}, token: ${_token != null ? _token!.substring(0, 10) + '...' : 'null'}',
          );
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          options.extra['disableLogging'] = true;
          return handler.next(options);
        },
        onError: (error, handler) async {
          debugPrint(
            '[AuthService] [${DateTime.now().toIso8601String()}] onError: Status: ${error.response?.statusCode}, Message: ${error.message}, URI: ${error.requestOptions.uri}',
          );
          if (error.response?.statusCode == 401) {
            debugPrint(
              '[AuthService] [${DateTime.now().toIso8601String()}] Unauthorized error, triggering logout',
            );
            await logout();
          }
          return handler.next(error);
        },
      ),
    );
    debugPrint(
      '[AuthService] [${DateTime.now().toIso8601String()}] AuthInterceptor added successfully',
    );
  }
}
