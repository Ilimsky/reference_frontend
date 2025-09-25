import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reference_frontend/providers/account_provider.dart';
import 'package:reference_frontend/providers/binding_provider.dart';
import 'package:reference_frontend/providers/department_provider.dart';
import 'package:reference_frontend/providers/employee_provider.dart';
import 'package:reference_frontend/providers/job_provider.dart';
import 'package:reference_frontend/providers/revizor_provider.dart';
import 'package:reference_frontend/providers/user_department_binding_provider.dart';
import 'package:reference_frontend/providers/user_provider.dart';
import 'package:reference_frontend/screens/login_screen.dart';
import 'package:reference_frontend/screens/reference_screen/reference_screen.dart';
import 'package:reference_frontend/service/api_service.dart';
import 'package:reference_frontend/service/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.autoLogin(); // Проверяем сохраненный токен
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),  // Один экземпляр с токеном

        ProxyProvider<AuthService, ApiService>(
          update: (_, authService, __) => ApiService(authService.dioInstance, authService),
        ),
        ChangeNotifierProxyProvider<ApiService, UserProvider>(
          create: (_) => UserProvider(ApiService(authService.dioInstance, authService)),
          update: (_, apiService, __) => UserProvider(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, BindingProvider>(
          create: (_) => BindingProvider(ApiService(authService.dioInstance, authService)),
          update: (_, apiService, __) => BindingProvider(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, DepartmentProvider>(
          create: (_) => DepartmentProvider(ApiService(authService.dioInstance, authService)),
          update: (_, apiService, __) => DepartmentProvider(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, EmployeeProvider>(
          create: (_) => EmployeeProvider(ApiService(authService.dioInstance, authService)),
          update: (_, apiService, __) => EmployeeProvider(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, RevizorProvider>(
          create: (_) => RevizorProvider(ApiService(authService.dioInstance, authService)),
          update: (_, apiService, __) => RevizorProvider(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, JobProvider>(
          create: (_) => JobProvider(ApiService(authService.dioInstance, authService)),
          update: (_, apiService, __) => JobProvider(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, AccountProvider>(
          create: (_) => AccountProvider(ApiService(authService.dioInstance, authService)),
          update: (_, apiService, __) => AccountProvider(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, UserDepartmentBindingProvider>(
          create: (_) => UserDepartmentBindingProvider(ApiService(authService.dioInstance, authService)),
          update: (_, apiService, __) => UserDepartmentBindingProvider(apiService),
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => HomeScreen(), // Основной экран из второго варианта
      },
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
                final authService = Provider.of<AuthService>(context, listen: false);

                await authService.logout();

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