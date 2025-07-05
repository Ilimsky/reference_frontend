import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reference_frontend/screens/reference_screen/revizors_tab.dart';
import 'package:reference_frontend/screens/reference_screen/users_tab.dart';

import '../../providers/DepartmentProvider.dart';
import '../../providers/EmployeeProvider.dart';
import '../../providers/RevizorProvider.dart';
import 'accounts_tab.dart';
import 'bindings_tab.dart';
import 'departments_tab.dart';
import 'employees_tab.dart';
import 'jobs_tab.dart';

class ReferenceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7, // Количество вкладок
      child: Scaffold(
        appBar: AppBar(
          title: Text('Справочник'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Привязка'),
              Tab(text: 'Филиалы'),
              Tab(text: 'Сотрудники'),
              Tab(text: 'Ревизоры'),
              Tab(text: 'Должности'),
              Tab(text: 'Счета'),
              Tab(text: 'Пользователи'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BindingsTab(), // Вкладка для привязки
            DepartmentsTab(), // Вкладка для филиалов
            EmployeesTab(), // Вкладка для сотрудников
            RevizorsTab(), // Вкладка для ревизоров
            JobsTab(), // Вкладка для должностей
            AccountsTab(), // Вкладка для счетов
            UsersTab(), // Вкладка для счетов
          ],
        ),
      ),
    );
  }
}
