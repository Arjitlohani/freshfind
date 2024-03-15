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
  TextEditingController _roleController = TextEditingController();

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
            ElevatedButton(
              onPressed: _addUser,
              child: Text('Add User'),
            ),
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
          obscureText: true,
          decoration: InputDecoration(labelText: 'Password'),
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
        TextFormField(
          controller: _roleController,
          decoration: InputDecoration(labelText: 'Role'),
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
          'username': _usernameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'phone_number': _phoneNumberController.text,
          'address': _addressController.text,
          'role': int.parse(_roleController.text),
        }),
      );

      if (response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        throw Exception('Failed to add user: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Failed to add user. Please try again later.');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('User added successfully.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearTextFields();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _clearTextFields() {
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _phoneNumberController.clear();
    _addressController.clear();
    _roleController.clear();
  }
}
