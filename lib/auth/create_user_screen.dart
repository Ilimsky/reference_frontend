import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'auth_service.dart';

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

  @override
  Widget build(BuildContext context) {
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
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Введите имя' : null,
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
                    val == true
                        ? _selectedRoles.add('ROLE_USER')
                        : _selectedRoles.remove('ROLE_USER');
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Admin'),
                value: _selectedRoles.contains('ROLE_ADMIN'),
                onChanged: (val) {
                  setState(() {
                    val == true
                        ? _selectedRoles.add('ROLE_ADMIN')
                        : _selectedRoles.remove('ROLE_ADMIN');
                  });
                },
              ),
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

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await userProvider.createUser(
        _usernameController.text,
        _passwordController.text,
        _selectedRoles,
      );
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Пользователь создан')),
      );
      Navigator.pop(context);
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Ошибка при создании: $e')),
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
