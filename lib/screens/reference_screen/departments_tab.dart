import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_service.dart';
import '../../providers/DepartmentProvider.dart';

class DepartmentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final departmentProvider = Provider.of<DepartmentProvider>(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    bool isSuperAdmin = authService.roles.contains('ROLE_SUPERADMIN');
    bool isAdmin = authService.roles.contains('ROLE_ADMIN');

    bool canEdit = isSuperAdmin || isAdmin;
    bool canDelete = isSuperAdmin;
    bool canCreate = isSuperAdmin || isAdmin;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              if (canCreate)
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    final textController = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Добавить филиал'),
                        content: TextField(controller: textController),
                        actions: [
                          TextButton(
                            onPressed: () {
                              if (textController.text.isNotEmpty) {
                                departmentProvider.createDepartment(textController.text);
                                Navigator.pop(context);
                              }
                            },
                            child: Text('Добавить'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        Expanded(
          child: departmentProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: departmentProvider.departments.length,
            itemBuilder: (context, index) {
              final dept = departmentProvider.departments[index];
              return ListTile(
                title: Text(dept.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (canEdit)
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          final textController = TextEditingController(text: dept.name);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Редактировать филиал'),
                              content: TextField(controller: textController),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    if (textController.text.isNotEmpty) {
                                      departmentProvider.updateDepartment(dept.id, textController.text);
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text('Сохранить'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    if (canDelete)
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _showDeleteDialog(context, dept.id, departmentProvider),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, int departmentId, DepartmentProvider departmentProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить филиал'),
        content: Text('Вы уверены, что хотите удалить этот филиал?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Отмена')),
          TextButton(
            onPressed: () {
              departmentProvider.deleteDepartment(departmentId);
              Navigator.pop(context);
            },
            child: Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
