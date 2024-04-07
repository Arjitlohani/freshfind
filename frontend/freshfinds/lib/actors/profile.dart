import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freshfinds/api/api.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Define variables to store user data
  String _name = '';
  String _email = '';
  String _password = '';

  // Method to fetch user data from the backend
  Future<void> _fetchUserData() async {
    // Implement API call to fetch user data
    // Replace the URL with your actual endpoint
    final url = Uri.parse('http://$ipAddress:$port/user/profile');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Extract user data from response
        setState(() {
          _name = responseData['name'];
          _email = responseData['email'];
          // You might want to handle password separately based on your requirements
        });
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            // Add your profile picture widget here
            // You can use a CircleAvatar or any other widget to display the profile picture

            // User Information Form
            TextFormField(
              initialValue: _name,
              decoration: InputDecoration(labelText: 'Name'),
              onChanged: (value) {
                setState(() {
                  _name = value;
                });
              },
            ),
            TextFormField(
              initialValue: _email,
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: (value) {
                setState(() {
                  _email = value;
                });
              },
            ),

            // Change Password Form
            TextFormField(
              decoration: InputDecoration(labelText: 'Current Password'),
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  _password = value;
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),

            // Update Profile Button
            ElevatedButton(
              onPressed: () {
                _updateProfile();
              },
              child: Text('Update Profile'),
            ),

            // Change Password Button
            ElevatedButton(
              onPressed: () {
                _changePassword();
              },
              child: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  // Method to update user profile
  void _updateProfile() {
    // Implement API call to update user profile
    // You'll need to send the updated _name and _email to the backend
  }

  // Method to change user password
  void _changePassword() {
    // Implement API call to change user password
    // You'll need to send the current password and new password to the backend
  }
}
