import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reference_frontend/auth/user.dart';
import 'auth_service.dart';

class EditUserDialog extends StatefulWidget {
  final User user;

  const EditUserDialog({super.key, required this.user});

  @override
  _EditUserDialogState createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late Set<String> _selectedRoles;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _passwordController = TextEditingController();
    _selectedRoles = Set.from(widget.user.roles);
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isSuperAdmin = authService.hasRole('ROLE_SUPERADMIN');
    final isAdmin = authService.hasRole('ROLE_ADMIN');

    final canEditUsername = isSuperAdmin || (isAdmin &&
        !widget.user.roles.contains('ROLE_SUPERADMIN') &&
        !widget.user.roles.contains('ROLE_ADMIN'));

    return AlertDialog(
      title: const Text('Редактировать пользователя'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Имя пользователя'),
              enabled: canEditUsername,
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Новый пароль (необязательно)',
              ),
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
              onChanged: isSuperAdmin
                  ? (val) {
                setState(() {
                  val == true
                      ? _selectedRoles.add('ROLE_ADMIN')
                      : _selectedRoles.remove('ROLE_ADMIN');
                });
              }
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              'username': _usernameController.text,
              'password': _passwordController.text,
              'roles': _selectedRoles.toList(),
            });
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
