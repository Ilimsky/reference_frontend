import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_service.dart';
import '../../providers/BindingProvider.dart';
import '../../providers/DepartmentProvider.dart';
import '../../providers/EmployeeProvider.dart';

class BindingsTab extends StatefulWidget {
  @override
  _BindingsTabState createState() => _BindingsTabState();
}

class _BindingsTabState extends State<BindingsTab> {
  int? selectedEmployeeId;
  int? selectedDepartmentId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<BindingProvider>(context, listen: false).fetchBindings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final departmentProvider = Provider.of<DepartmentProvider>(context);
    final bindingProvider = Provider.of<BindingProvider>(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    bool isSuperAdmin = authService.roles.contains('ROLE_SUPERADMIN');
    bool isAdmin = authService.roles.contains('ROLE_ADMIN');

    bool canEdit = isSuperAdmin || isAdmin;
    bool canDelete = isSuperAdmin;
    bool canCreate = isSuperAdmin || isAdmin;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: 'Сотрудник'),
                  value: selectedEmployeeId,
                  items: employeeProvider.employees
                      .map((e) =>
                      DropdownMenuItem(value: e.id, child: Text(e.name)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedEmployeeId = value),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: 'Филиал'),
                  value: selectedDepartmentId,
                  items: departmentProvider.departments
                      .map((d) =>
                      DropdownMenuItem(value: d.id, child: Text(d.name)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedDepartmentId = value),
                ),
              ),
              SizedBox(width: 8),
              if (canCreate)
                ElevatedButton(
                  onPressed:
                  selectedEmployeeId != null && selectedDepartmentId != null
                      ? () {
                    bindingProvider.createBinding(
                      employeeId: selectedEmployeeId!,
                      departmentId: selectedDepartmentId!,
                    );
                  }
                      : null,
                  child: Text('Привязать'),
                ),
            ],
          ),
        ),
        Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: bindingProvider.bindings.length,
            itemBuilder: (context, index) {
              final binding = bindingProvider.bindings[index];

              final employee = binding.employee?.name ?? 'Не найдено';
              final department = binding.department?.name ?? 'Не найдено';

              return ListTile(
                title: Text('$employee → $department'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (canEdit)
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () =>
                            _showEditDialog(context, bindingProvider, binding),
                      ),
                    if (canDelete)
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () =>
                            _confirmDelete(context, bindingProvider, binding.id),
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

  void _showEditDialog(
      BuildContext context, BindingProvider provider, binding) {
    int? employeeId = binding.employee?.id;
    int? departmentId = binding.department?.id;

    final employeeProvider =
    Provider.of<EmployeeProvider>(context, listen: false);
    final departmentProvider =
    Provider.of<DepartmentProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Редактировать привязку'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'Сотрудник'),
                value: employeeProvider.employees.any((e) => e.id == employeeId)
                    ? employeeId
                    : null,
                items: employeeProvider.employees
                    .map((e) =>
                    DropdownMenuItem(value: e.id, child: Text(e.name)))
                    .toList(),
                onChanged: (value) => setState(() => employeeId = value),
              ),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'Филиал'),
                value: departmentProvider.departments
                    .any((d) => d.id == departmentId)
                    ? departmentId
                    : null,
                items: departmentProvider.departments
                    .map((d) =>
                    DropdownMenuItem(value: d.id, child: Text(d.name)))
                    .toList(),
                onChanged: (value) => setState(() => departmentId = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Сохранить'),
              onPressed: () {
                if (employeeId != null && departmentId != null) {
                  provider.updateBinding(
                    binding.id,
                    employeeId: employeeId!,
                    departmentId: departmentId!,
                  );
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, BindingProvider provider, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить привязку?'),
        content: Text('Вы уверены, что хотите удалить эту привязку?'),
        actions: [
          TextButton(
            child: Text('Отмена'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Удалить', style: TextStyle(color: Colors.red)),
            onPressed: () {
              provider.deleteBinding(id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
