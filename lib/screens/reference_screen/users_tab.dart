import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_service.dart';
import '../../auth/create_user_screen.dart';
import '../../auth/edit_user_dialog.dart';
import '../../auth/user.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';

class UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Column(
      children: [
        if (authService.hasRole('ROLE_SUPERADMIN'))
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addUser(context, userProvider),
                ),
              ],
            ),
          ),
        Expanded(
          child: userProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: userProvider.users.length,
            itemBuilder: (context, index) {
              final user = userProvider.users[index];
              return ListTile(
                title: Text(user.username),
                subtitle: Text(user.roles.join(', ')),
                trailing: (authService.hasRole('ROLE_ADMIN') ||
                    authService.hasRole('ROLE_SUPERADMIN'))
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (authService.hasRole('ROLE_SUPERADMIN') &&
                        !user.roles.contains('ROLE_SUPERADMIN'))
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteUserDialog(context, user.id, userProvider),
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editUser(context, user, userProvider),
                    ),
                  ],
                )
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _addUser(BuildContext context, UserProvider userProvider) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateUserScreen()),
    );

    try {
      await userProvider.fetchUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось обновить список пользователей: $e')),
      );
    }
  }

  Future<void> _editUser(BuildContext context, User user, UserProvider userProvider) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditUserDialog(user: user),
    );

    if (result != null) {
      try {
        await userProvider.updateUser(
          user.id,
          result['username'] ?? user.username,
          Set<String>.from(result['roles'] ?? user.roles),
          password: result['password']?.isNotEmpty == true ? result['password'] : null,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пользователь успешно обновлён')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при обновлении: $e')),
        );
      }
    }
  }

  void _showDeleteUserDialog(BuildContext context, int userId, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пользователя'),
        content: const Text('Вы уверены, что хотите удалить этого пользователя?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await userProvider.deleteUser(userId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Пользователь удалён')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка при удалении: $e')),
                );
              }
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
