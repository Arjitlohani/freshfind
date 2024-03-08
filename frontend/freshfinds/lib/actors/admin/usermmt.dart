// usermmt.dart
import 'package:flutter/material.dart';

class UserManagementScreen extends StatelessWidget {
  final List<User> users;

  const UserManagementScreen({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user.name),
            subtitle: Text(user.email),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Handle delete user action
              },
            ),
          );
        },
      ),
    );
  }
}

class User {
  final String name;
  final String email;

  User({required this.name, required this.email});
}
