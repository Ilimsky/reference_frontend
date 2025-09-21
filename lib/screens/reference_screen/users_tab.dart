import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../service/auth_service.dart';
import '../create_user_screen.dart';
import '../../models/User.dart';
import '../../models/UserDepartmentBinding.dart';
import '../../providers/user_provider.dart';
import '../../providers/user_department_binding_provider.dart';
import '../../providers/department_provider.dart';
import '../edit_user_dialog.dart';

class UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final bindingProvider = Provider.of<UserDepartmentBindingProvider>(context);
    final departmentProvider = Provider.of<DepartmentProvider>(context);

    // Загружаем привязки и департаменты при открытии таба
    Future.microtask(() {
      // print('Fetching bindings and departments');
      bindingProvider.fetchBindings();
      departmentProvider.fetchDepartments();
    });

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
              final isTargetSuperAdmin = user.roles.contains('ROLE_SUPERADMIN');
              final isCurrentSuperAdmin = authService.hasRole('ROLE_SUPERADMIN');
              final isCurrentAdmin = authService.hasRole('ROLE_ADMIN');

              final canEdit = isCurrentSuperAdmin || (isCurrentAdmin && !isTargetSuperAdmin);
              final canDelete = isCurrentSuperAdmin && !isTargetSuperAdmin;

              // Получаем привязки для текущего пользователя
              final userBindings = bindingProvider.bindings
                  .where((binding) => binding.user?.id == user.id)
                  .toList();

              // Формируем текст с привязками в формате "user → department"
              final bindingTexts = userBindings.map((binding) {
                final user = binding.user?.username ?? 'Не найдено';
                final department = binding.department?.name ?? 'Не найдено';
                return '$user → $department';
              }).toList();

              // print('Rendering user: ${user.username}, bindings: $bindingTexts');

              return ListTile(
                title: Text(user.username),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.roles.join(', ')),
                    if (bindingTexts.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          ...bindingTexts
                              .map(
                                (text) => Text(
                              text,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                              .toList(),
                        ],
                      ),
                  ],
                ),
                trailing: canEdit
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (canDelete)
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteUserDialog(
                          context,
                          user.id,
                          userProvider,
                          bindingProvider,
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editUser(
                        context,
                        user,
                        userProvider,
                        bindingProvider,
                        departmentProvider,
                        canEdit,
                      ),
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

  Future<void> _editUser(
      BuildContext context,
      User user,
      UserProvider userProvider,
      UserDepartmentBindingProvider bindingProvider,
      DepartmentProvider departmentProvider,
      bool canEdit,
      ) async {
    if (!canEdit) {
      // print('Edit not allowed for user: ${user.username}');
      return;
    }

    // print('Showing edit dialog for user: ${user.username}');
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditUserDialog(
        user: user,
        binding: bindingProvider.bindings.firstWhere(
              (b) => b.userId == user.id,
          orElse: () => UserDepartmentBinding(id: 0, userId: user.id, departmentId: 0),
        ),
      ),
    );

    if (result != null) {
      try {
        print('Updating user: ${user.username} with new data: $result');
        await userProvider.updateUser(
          user.id,
          result['username'] ?? user.username,
          Set<String>.from(result['roles'] ?? user.roles),
          password: result['password']?.isNotEmpty == true ? result['password'] : null,
        );

        // Обновляем или создаем привязку, если роль USER и выбран отдел
        if (result['roles'].contains('ROLE_USER') && result['departmentId'] != null) {
          final existingBinding = bindingProvider.bindings.firstWhere(
                (b) => b.userId == user.id,
            orElse: () => UserDepartmentBinding(id: 0, userId: user.id, departmentId: 0),
          );

          if (existingBinding.id != 0) {
            // Обновляем существующую привязку
            print('Updating binding for userId: ${user.id}, departmentId: ${result['departmentId']}');
            await bindingProvider.updateBinding(
              existingBinding.id,
              userId: user.id,
              departmentId: result['departmentId'],
            );
          } else {
            // Создаем новую привязку
            print('Creating new binding for userId: ${user.id}, departmentId: ${result['departmentId']}');
            await bindingProvider.createBinding(
              userId: user.id,
              departmentId: result['departmentId'],
            );
          }
        } else if (!result['roles'].contains('ROLE_USER') && bindingProvider.bindings.any((b) => b.userId == user.id)) {
          // Удаляем привязку, если роль USER снята
          print('Removing binding for userId: ${user.id} as ROLE_USER was removed');
          await bindingProvider.deleteBindingByUser(user.id);
        }

        print('User updated successfully: ${user.username}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пользователь успешно обновлён')),
        );
      } catch (e) {
        print('Error updating user or binding: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при обновлении: $e')),
        );
      }
    } else {
      print('Edit dialog cancelled for user: ${user.username}');
    }
  }

  Future<void> _addUser(BuildContext context, UserProvider userProvider) async {
    // print('Navigating to CreateUserScreen');
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateUserScreen()),
    );

    try {
      // print('Fetching users after adding a new user');
      await userProvider.fetchUsers();
      // print('Users fetched successfully: ${userProvider.users.length} users');
    } catch (e) {
      // print('Error fetching users after adding: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось обновить список пользователей: $e')),
      );
    }
  }

  void _showDeleteUserDialog(
      BuildContext context,
      int userId,
      UserProvider userProvider,
      UserDepartmentBindingProvider bindingProvider,
      ) {
    // print('Showing delete user dialog for userId: $userId');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пользователя'),
        content: const Text('Вы уверены, что хотите удалить этого пользователя?'),
        actions: [
          TextButton(
            onPressed: () {
              // print('Cancel button pressed for userId: $userId');
              Navigator.pop(context);
            },
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              // print('Delete button pressed for userId: $userId');
              try {
                // print('Attempting to delete user with id: $userId');
                // Удаляем привязки пользователя
                // print('Deleting bindings for userId: $userId');
                await bindingProvider.deleteBindingByUser(userId);
                // print('Bindings deleted for userId: $userId');
                // Удаляем пользователя
                await userProvider.deleteUser(userId);
                // print('User deleted successfully: $userId');
                // Обновляем список пользователей
                // print('Fetching users after deletion');
                await userProvider.fetchUsers();
                // print('Users fetched successfully: ${userProvider.users.length} users');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Пользователь удалён')),
                );
              } catch (e) {
                // print('Error during user deletion: $e');
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