import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/RevizorProvider.dart';

class RevizorsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final revizorProvider = Provider.of<RevizorProvider>(context);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
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

  // Метод для отображения диалога удаления сотрудника
  void _showDeleteDialog(BuildContext context, int revizorId, RevizorProvider revizorProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить сотрудника'),
        content: Text('Вы уверены, что хотите удалить этого сотрудника?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Закрыть диалог
            },
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              revizorProvider.deleteRevizor(revizorId); // Удалить должность
              Navigator.pop(context); // Закрыть диалог
            },
            child: Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}