import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'user_service.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  _CreateUserScreenState createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  Set<String> _selectedRoles = {'ROLE_USER'};

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create New User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Select Roles:'),
              CheckboxListTile(
                title: const Text('User'),
                value: _selectedRoles.contains('ROLE_USER'),
                onChanged: (value) => setState(() {
                  if (value == true) {
                    _selectedRoles.add('ROLE_USER');
                  } else {
                    _selectedRoles.remove('ROLE_USER');
                  }
                }),
              ),
              CheckboxListTile(
                title: const Text('Admin'),
                value: _selectedRoles.contains('ROLE_ADMIN'),
                onChanged: (value) => setState(() {
                  if (value == true) {
                    _selectedRoles.add('ROLE_ADMIN');
                  } else {
                    _selectedRoles.remove('ROLE_ADMIN');
                  }
                }),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _createUser(),
                child: const Text('Create User'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        await Provider.of<UserService>(context, listen: false).createUser(
          username: _usernameController.text,
          password: _passwordController.text,
          roles: _selectedRoles,
        );

        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('User created successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating user: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}