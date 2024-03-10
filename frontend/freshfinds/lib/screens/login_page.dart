import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    final String url = 'http://100.64.231.62:3000/login';
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    final Map<String, String> body = {
      'email': emailController.text,
      'password': passwordController.text,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      // Print the response body to debug
      print(response.body);

      // Decode the response JSON
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Check if the response contains the 'role_id' field
      if (responseData.containsKey('role')) {
        // Extract the roleId from the response data
        final int roleId = responseData['role'];

        // Show login successful message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful')),
        );

        // Navigate to the appropriate dashboard based on roleId
        _navigateToDashboard(context, roleId);
      } else {
        // Show error message if 'role_id' field is missing
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Role ID not found in response')),
        );
      }
    } else {
      // Show error message if response status code is not 200
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed')),
      );
    }
  }

  void _navigateToDashboard(BuildContext context, int roleId) {
    switch (roleId) {
      case 1:
        Navigator.pushNamed(context, '/adminDashboard');
        break;
      case 2:
        Navigator.pushNamed(context, '/vendorDashboard');
        break;
      case 3:
        Navigator.pushNamed(context, '/customerDashboard');
        break;
      case 4:
        Navigator.pushNamed(context, '/driverDashboard');
        break;
      default:
        // Handle unknown roleId or unexpected data
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: Text('Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}
