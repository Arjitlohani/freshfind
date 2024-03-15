import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  List<dynamic> _users = []; // List to store user data

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.113:3000/users'));

      if (response.statusCode == 200) {
        setState(() {
          _users = jsonDecode(response.body)['users'];
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error fetching users: $e');
      // Handle error (e.g., show a snackbar to inform the user)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildUserForm(),
            SizedBox(height: 20),
            _buildUserList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(labelText: 'Username'),
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(labelText: 'Email'),
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: _phoneNumberController,
          decoration: InputDecoration(labelText: 'Phone Number'),
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: _addressController,
          decoration: InputDecoration(labelText: 'Address'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _addUser,
          child: Text('Add User'),
        ),
      ],
    );
  }

  Widget _buildUserList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'User List',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _users.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_users[index]['user_name']),
              subtitle: Text(_users[index]['email']),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _confirmDeleteUser(_users[index]['user_id']),
              ),
            );
          },
        ),
      ],
    );
  }

  void _addUser() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.113:3000/users'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_name': _usernameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'phone_number': _phoneNumberController.text,
          'address': _addressController.text,
          'role': '3',
        }),
      );

      if (response.statusCode == 201) {
        // User added successfully, fetch users again to update the list
        fetchUsers();
        // Clear text fields
        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _phoneNumberController.clear();
        _addressController.clear();
      } else {
        // If the server responds with an error status code
        throw Exception('Failed to add user: ${response.statusCode}');
      }
    } catch (e) {
      // Handle error (e.g., show a snackbar to inform the user)
      print('Error adding user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add user. Please try again later.')),
      );
    }
  }

  void _confirmDeleteUser(int userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this user?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUser(userId);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(int userId) async {
    try {
      final response = await http
          .delete(Uri.parse('http://192.168.1.113:3000/users/$userId'));

      if (response.statusCode == 200) {
        // User deleted successfully, fetch users again to update the list
        fetchUsers();
      } else {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      print('Error deleting user: $e');
      // Handle error (e.g., show a snackbar to inform the user)
    }
  }
}
