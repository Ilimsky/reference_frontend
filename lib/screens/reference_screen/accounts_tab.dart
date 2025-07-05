import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_service.dart';
import '../../providers/AccountProvider.dart';

class AccountsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    bool isSuperAdmin = authService.roles.contains('ROLE_SUPERADMIN');
    bool isAdmin = authService.roles.contains('ROLE_ADMIN');
    bool isUser = authService.roles.contains('ROLE_USER');

    bool canEdit = isSuperAdmin || isAdmin;
    bool canDelete = isSuperAdmin;  // удалять может только суперадмин
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
                        title: Text('Добавить счёт'),
                        content: TextField(controller: textController),
                        actions: [
                          TextButton(
                            onPressed: () {
                              if (textController.text.isNotEmpty) {
                                accountProvider.createAccount(textController.text);
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
          child: accountProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: accountProvider.accounts.length,
            itemBuilder: (context, index) {
              final account = accountProvider.accounts[index];
              return ListTile(
                title: Text(account.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (canEdit)
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          final textController = TextEditingController(text: account.name);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Редактировать счёт'),
                              content: TextField(controller: textController),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    if (textController.text.isNotEmpty) {
                                      accountProvider.updateAccount(account.id, textController.text);
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
                        onPressed: () => _showDeleteAccountDialog(context, account.id, accountProvider),
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

  void _showDeleteAccountDialog(BuildContext context, int accountId, AccountProvider accountProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить счёт'),
        content: Text('Вы уверены, что хотите удалить этот счёт?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              accountProvider.deleteAccount(accountId);
              Navigator.pop(context);
            },
            child: Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
