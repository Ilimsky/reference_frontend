import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/department_provider.dart';
import '../providers/user_department_binding_provider.dart';
import '../service/auth_service.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  Set<String> _selectedRoles = {'ROLE_USER'};
  int? _selectedDepartmentId;

  @override
  void initState() {
    super.initState();
    // Загружаем филиалы при инициализации
    Future.microtask(() {
      print('Fetching departments for CreateUserScreen');
      Provider.of<DepartmentProvider>(context, listen: false).fetchDepartments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final departmentProvider = Provider.of<DepartmentProvider>(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    bool isSuperAdmin = authService.roles.contains('ROLE_SUPERADMIN');
    bool isAdmin = authService.roles.contains('ROLE_ADMIN');

    // Показываем выбор филиала только для пользователей с ROLE_USER
    bool showDepartmentSelection = _selectedRoles.contains('ROLE_USER') && (isSuperAdmin || isAdmin);

    return Scaffold(
      appBar: AppBar(title: const Text('Создать пользователя')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Имя пользователя'),
                validator: (value) => (value == null || value.isEmpty) ? 'Введите имя' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Пароль'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите пароль';
                  }
                  if (value.length < 6) {
                    return 'Минимум 6 символов';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Повторите пароль'),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Пароли не совпадают';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Роли:'),
              CheckboxListTile(
                title: const Text('User'),
                value: _selectedRoles.contains('ROLE_USER'),
                onChanged: (val) {
                  setState(() {
                    val == true ? _selectedRoles.add('ROLE_USER') : _selectedRoles.remove('ROLE_USER');
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Admin'),
                value: _selectedRoles.contains('ROLE_ADMIN'),
                onChanged: isSuperAdmin
                    ? (val) {
                  setState(() {
                    val == true ? _selectedRoles.add('ROLE_ADMIN') : _selectedRoles.remove('ROLE_ADMIN');
                  });
                }
                    : null,
              ),
              if (showDepartmentSelection) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Филиал (для пользователя)'),
                  value: _selectedDepartmentId,
                  items: departmentProvider.departments
                      .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedDepartmentId = value),
                  validator: (value) {
                    if (_selectedRoles.contains('ROLE_USER') && value == null) {
                      return 'Выберите филиал для пользователя';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleCreateUser,
                child: const Text('Создать'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCreateUser() async {
    if (!_formKey.currentState!.validate()) return;

    final bindingProvider = Provider.of<UserDepartmentBindingProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      // Проверяем роли текущего пользователя
      print('Создание пользователя: ${_usernameController.text}, роли: $_selectedRoles');
      print('Роли текущего пользователя: ${authService.roles}');

      // Проверяем права перед созданием привязки
      if (_selectedRoles.contains('ROLE_USER') && _selectedDepartmentId != null) {
        if (!authService.roles.contains('ROLE_SUPERADMIN') && !authService.roles.contains('ROLE_ADMIN')) {
          throw Exception('Недостаточно прав для создания привязки. Требуется роль ADMIN или SUPERADMIN');
        }
      }

      // Создаем пользователя и, при необходимости, привязку
      await bindingProvider.createUserWithBinding(
        username: _usernameController.text,
        password: _passwordController.text,
        roles: _selectedRoles,
        departmentId: _selectedDepartmentId, // Может быть null
      );

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Пользователь создан')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Ошибка при создании пользователя или привязки: $e');
      String errorMessage = 'Ошибка при создании: $e';
      if (e.toString().contains('Недостаточно прав')) {
        errorMessage = 'Недостаточно прав для создания привязки. Требуется роль ADMIN или SUPERADMIN';
      } else if (e.toString().contains('Binding already exists')) {
        errorMessage = 'Пользователь уже привязан к филиалу';
      } else if (e.toString().contains('User not found')) {
        errorMessage = 'Пользователь не найден';
      } else if (e.toString().contains('Department not found')) {
        errorMessage = 'Филиал не найден';
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}