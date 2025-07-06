import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_service.dart';
import '../../providers/RevizorProvider.dart';

class RevizorsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final revizorProvider = Provider.of<RevizorProvider>(context);
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
                        title: Text('Добавить сотрудника'),
                        content: TextField(controller: textController),
                        actions: [
                          TextButton(
                            onPressed: () {
                              if (textController.text.isNotEmpty) {
                                revizorProvider.createRevizor(textController.text);
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
          child: revizorProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: revizorProvider.revizors.length,
            itemBuilder: (context, index) {
              final revizor = revizorProvider.revizors[index];
              return ListTile(
                title: Text(revizor.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (canEdit)
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          final textController = TextEditingController(text: revizor.name);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Редактировать сотрудника'),
                              content: TextField(controller: textController),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    if (textController.text.isNotEmpty) {
                                      revizorProvider.updateRevizor(revizor.id, textController.text);
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
                        onPressed: () => _showDeleteDialog(context, revizor.id, revizorProvider),
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

  void _showDeleteDialog(BuildContext context, int revizorId, RevizorProvider revizorProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить сотрудника'),
        content: Text('Вы уверены, что хотите удалить этого сотрудника?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Отмена')),
          TextButton(
            onPressed: () {
              revizorProvider.deleteRevizor(revizorId);
              Navigator.pop(context);
            },
            child: Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
