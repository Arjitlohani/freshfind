import 'package:flutter/material.dart';
import 'package:freshfinds/models/user.dart';
import 'package:freshfinds/providers/user_provider.dart';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../models/port.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailOrUsernameController =
      TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _showPassword = false; // Variable to control password visibility

  Future<void> _login(BuildContext context) async {
    const String url = 'http://$ipAddress:$port/login';
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    final Map<String, String> body = {
      'emailOrUsername': emailOrUsernameController.text,
      'password': passwordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Decode the response JSON
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('role') &&
            responseData.containsKey('user_id')) {
          final int roleId = responseData['role'];
          final int userId = responseData['user_id'];

          // Set the user ID in UserProvider
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          userProvider.user = User(userId: userId);

          // Show login successful message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Login successful'),
                backgroundColor: Color.fromARGB(166, 3, 95, 6)),
          );

          print('Role ID: $roleId, User ID: $userId');
          _navigateToDashboard(context, roleId, userId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Role ID or User ID not found in response')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed'),
            backgroundColor: Color.fromARGB(149, 238, 29, 15),
          ),
        );
      }
    } catch (e) {
      print('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error during login. Please try again later.')),
      );
    }
  }

  void _navigateToDashboard(BuildContext context, int roleId, int userId) {
    switch (roleId) {
      case 1:
        Navigator.pushNamed(context, '/adminDashboard');
        break;
      case 2:
        Navigator.pushNamed(context, '/vendorDashboard',
            arguments: {'userId': userId});
        break;
      case 3:
        Navigator.pushReplacementNamed(
          context,
          '/customerDashboard',
          arguments: {'userId': userId},
        );
        break;
      case 4:
        Navigator.pushNamed(context, '/driverDashboard');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed role not found'),
            backgroundColor: Color.fromARGB(149, 238, 29, 15),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: emailOrUsernameController,
                decoration: const InputDecoration(labelText: 'Email/Username'),
              ),
              const SizedBox(height: 16), // Add some spacing between fields
              TextFormField(
                controller: passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16), // Add some spacing between fields
              ElevatedButton(
                onPressed: () => _login(context),
                child: const Text('Login'),
              ),
              const SizedBox(height: 16), // Add some spacing between fields
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text('Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
