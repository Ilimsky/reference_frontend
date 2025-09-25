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

class UsersTab extends StatefulWidget {
  @override
  _UsersTabState createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() {
        final bindingProvider = Provider.of<UserDepartmentBindingProvider>(context, listen: false);
        final departmentProvider = Provider.of<DepartmentProvider>(context, listen: false);

        bindingProvider.fetchBindings();
        departmentProvider.fetchDepartments();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final bindingProvider = Provider.of<UserDepartmentBindingProvider>(context);
    final departmentProvider = Provider.of<DepartmentProvider>(context);

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

              final userBindings = bindingProvider.bindings
                  .where((binding) => binding.user?.id == user.id)
                  .toList();

              final bindingTexts = userBindings.map((binding) {
                final user = binding.user?.username ?? 'Не найдено';
                final department = binding.department?.name ?? 'Не найдено';
                return '$user → $department';
              }).toList();

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
      return;
    }

    // СОХРАНИТЬ ЗАРАНЕЕ
    final scaffoldMessenger = ScaffoldMessenger.of(context);

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
        await userProvider.updateUser(
          user.id,
          result['username'] ?? user.username,
          Set<String>.from(result['roles'] ?? user.roles),
          password: result['password']?.isNotEmpty == true ? result['password'] : null,
        );

        if (result['roles'].contains('ROLE_USER') && result['departmentId'] != null) {
          final existingBinding = bindingProvider.bindings.firstWhere(
                (b) => b.userId == user.id,
            orElse: () => UserDepartmentBinding(id: 0, userId: user.id, departmentId: 0),
          );

          if (existingBinding.id != 0) {
            await bindingProvider.updateBinding(
              existingBinding.id,
              userId: user.id,
              departmentId: result['departmentId'],
            );
          } else {
            await bindingProvider.createBinding(
              userId: user.id,
              departmentId: result['departmentId'],
            );
          }
        } else if (!result['roles'].contains('ROLE_USER') && bindingProvider.bindings.any((b) => b.userId == user.id)) {
          await bindingProvider.deleteBindingByUser(user.id);
        }

        // ИСПОЛЬЗОВАТЬ СОХРАНЕННУЮ ССЫЛКУ
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Пользователь успешно обновлён')),
        );
      } catch (e) {
        // ИСПОЛЬЗОВАТЬ СОХРАНЕННУЮ ССЫЛКУ
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Ошибка при обновлении: $e')),
        );
      }
    }
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

  void _showDeleteUserDialog(
      BuildContext context,
      int userId,
      UserProvider userProvider,
      UserDepartmentBindingProvider bindingProvider,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пользователя'),
        content: const Text('Вы уверены, что хотите удалить этого пользователя?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await bindingProvider.deleteBindingByUser(userId);
                await userProvider.deleteUser(userId);
                await userProvider.fetchUsers();
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