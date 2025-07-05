import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_service.dart';
import '../../auth/create_user_screen.dart';
import '../../auth/edit_user_dialog.dart';
import '../../auth/user.dart';
import '../../auth/user_service.dart';

class UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userService = Provider.of<UserService>(context);

    return Column(
      children: [
        if (authService.hasRole('ROLE_SUPERADMIN'))
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addUser(context),
                ),
              ],
            ),
          ),
        Expanded(
          child: userService.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: userService.users.length,
            itemBuilder: (context, index) {
              final user = userService.users[index];
              return ListTile(
                title: Text(user.username),
                subtitle: Text(user.roles.join(', ')),
                trailing: authService.hasRole('ROLE_ADMIN') ||
                    authService.hasRole('ROLE_SUPERADMIN')
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (authService.hasRole('ROLE_SUPERADMIN') &&
                        !user.roles.contains('ROLE_SUPERADMIN'))
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            _showDeleteUserDialog(context, user.id),
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editUser(context, user),
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

  Future<void> _addUser(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateUserScreen()),
    );

    try {
      await Provider.of<UserService>(context, listen: false).fetchUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh user list: $e')),
      );
    }
  }

  Future<void> _editUser(BuildContext context, User user) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditUserDialog(user: user),
    );

    if (result != null) {
      try {
        await Provider.of<UserService>(context, listen: false).updateUser(
          id: user.id,
          username: result['username'] ?? user.username,
          roles: Set<String>.from(result['roles'] ?? user.roles),
          password: result['password']?.isNotEmpty == true ? result['password'] : null,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user: $e')),
        );
      }
    }
  }

  Future<void> _showDeleteUserDialog(BuildContext context, int userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Provider.of<UserService>(context, listen: false).deleteUser(userId);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user: $e')),
        );
      }
    }
  }
}