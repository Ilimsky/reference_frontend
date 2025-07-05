// edit_user_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reference_frontend/auth/user.dart';
import 'auth_service.dart';
import 'user_service.dart';

// Обновим EditUserDialog
class EditUserDialog extends StatefulWidget {
  final User user;

  const EditUserDialog({super.key, required this.user});

  @override
  _EditUserDialogState createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late Set<String> _selectedRoles;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _selectedRoles = Set.from(widget.user.roles);
    _usernameController = TextEditingController(text: widget.user.username);
    _passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isSuperAdmin = authService.hasRole('ROLE_SUPERADMIN');
    final isAdmin = authService.hasRole('ROLE_ADMIN');

    return AlertDialog(
      title: const Text('Edit User'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
              enabled:
                  isSuperAdmin ||
                  (isAdmin &&
                      !widget.user.roles.contains('ROLE_SUPERADMIN') &&
                      !widget.user.roles.contains('ROLE_ADMIN')),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'New Password (leave empty to keep current)',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            const Text('Roles:'),
            CheckboxListTile(
              title: const Text('User'),
              value: _selectedRoles.contains('ROLE_USER'),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedRoles.add('ROLE_USER');
                  } else {
                    _selectedRoles.remove('ROLE_USER');
                  }
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Admin'),
              value: _selectedRoles.contains('ROLE_ADMIN'),
              onChanged: isSuperAdmin
                  ? (value) {
                      setState(() {
                        if (value == true) {
                          _selectedRoles.add('ROLE_ADMIN');
                        } else {
                          _selectedRoles.remove('ROLE_ADMIN');
                        }
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
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              'username': _usernameController.text,
              'password': _passwordController.text,
              'roles': _selectedRoles.toList(),
            });
          },
          child: const Text('Save'),
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
