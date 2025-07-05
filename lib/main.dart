import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reference_frontend/providers/AccountProvider.dart';
import 'package:reference_frontend/providers/BindingProvider.dart';
import 'package:reference_frontend/providers/DepartmentProvider.dart';
import 'package:reference_frontend/providers/EmployeeProvider.dart';
import 'package:reference_frontend/providers/JobProvider.dart';
import 'package:reference_frontend/providers/RevizorProvider.dart';
import 'package:reference_frontend/screens/reference_screen/reference_screen.dart';

import 'api/ApiService.dart';
import 'auth/auth_service.dart';
import 'auth/login_screen.dart';
import 'auth/user_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        /// Auth и UserService
        ChangeNotifierProvider(create: (_) => AuthService()),
        ProxyProvider<AuthService, ApiService>(
          update: (_, authService, __) => ApiService(authService),
        ),
        ProxyProvider<AuthService, UserService>(
          update: (_, authService, __) => UserService(authService),
        ),

        /// Провайдеры, зависящие от ApiService
        ChangeNotifierProxyProvider<ApiService, BindingProvider>(
          create: (_) => BindingProvider(ApiService(AuthService())), // заглушка
          update: (_, apiService, __) => BindingProvider(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, DepartmentProvider>(
          create: (_) => DepartmentProvider(ApiService(AuthService())),
          update: (_, apiService, __) => DepartmentProvider(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, EmployeeProvider>(
          create: (_) => EmployeeProvider(ApiService(AuthService())),
          update: (_, apiService, __) => EmployeeProvider(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, RevizorProvider>(
          create: (_) => RevizorProvider(ApiService(AuthService())),
          update: (_, apiService, __) => RevizorProvider(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, JobProvider>(
          create: (_) => JobProvider(ApiService(AuthService())),
          update: (_, apiService, __) => JobProvider(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, AccountProvider>(
          create: (_) => AccountProvider(ApiService(AuthService())),
          update: (_, apiService, __) => AccountProvider(apiService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Админ панель',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Сохраняем маршрутизацию из первого варианта
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => HomeScreen(), // Основной экран из второго варианта
        // '/users': (context) => const UserListScreen(),
      },
      // home: HomeScreen(), // Убрали, так как используем initialRoute
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Администраторское приложение'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              try {
                // Get the AuthService instance
                final authService = Provider.of<AuthService>(context, listen: false);

                // Call logout
                await authService.logout();

                // Navigate back to login screen
                Navigator.of(context).pushReplacementNamed('/login');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка при выходе: $e')),
                );
              }
            },
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: ReferenceScreen(),
    );
  }
}