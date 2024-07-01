import 'package:flutter/material.dart';
import 'package:freshfinds/models/port.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DriverManagementScreen extends StatefulWidget {
  const DriverManagementScreen({Key? key}) : super(key: key);

  @override
  _DriverManagementScreenState createState() => _DriverManagementScreenState();
}

class _DriverManagementScreenState extends State<DriverManagementScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Driver'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(_usernameController, 'Username', TextInputType.text,
                (value) {
              return _validateUsername(value);
            }),
            _buildTextField(
                _emailController, 'Email', TextInputType.emailAddress,
                (value) async {
              if (value.isEmpty) {
                return 'Please enter an email';
              }
              if (!value.contains('@') || !value.contains('.com')) {
                return 'Please enter a valid email address';
              }
              return 'Correct';
            }),
            _buildTextField(_passwordController, 'Password', TextInputType.text,
                (value) async {
              if (value.isEmpty) {
                return 'Please enter a password';
              }
              return 'Correct';
            }),
            _buildTextField(
                _phoneNumberController, 'Phone Number', TextInputType.phone,
                (value) async {
              if (value.isEmpty) {
                return 'Please enter a phone number';
              }
              if (value.length != 10) {
                return 'Phone number must be 10 digits';
              }
              return 'Correct';
            }),
            _buildTextField(_addressController, 'Address', TextInputType.text,
                (value) async {
              if (value.isEmpty) {
                return 'Please enter an address';
              }
              return 'Correct';
            }),
            ElevatedButton(
              onPressed: _addUser,
              child: const Text('Add Driver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      TextInputType keyboardType, Future<String?> Function(String) validator) {
    return FutureBuilder<String?>(
      future: validator(controller.text),
      builder: (context, snapshot) {
        String? errorText = snapshot.data;
        return Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: errorText == null || errorText == 'Correct'
                  ? Colors.green
                  : Colors.red,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: controller,
                onChanged: (_) {
                  setState(() {}); // Trigger rebuild to update border color
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                ),
                keyboardType: keyboardType,
              ),
              const SizedBox(height: 4),
              if (errorText != null && errorText != 'Correct')
                Text(
                  errorText,
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        );
      },
    );
  }

  void _addUser() async {
    // Validate all input fields
    String usernameError = await _validateUsername(_usernameController.text);
    String emailError = _validateEmail(_emailController.text);
    String passwordError = _validatePassword(_passwordController.text);
    String phoneNumberError = _validatePhoneNumber(_phoneNumberController.text);
    String addressError = _validateAddress(_addressController.text);

    // Set the role to 4 by default for the vendor
    String role = '4';

    // Check if any input field has an error
    if (usernameError != 'Correct' ||
        emailError != 'Correct' ||
        passwordError != 'Correct' ||
        phoneNumberError != 'Correct' ||
        addressError != 'Correct') {
      // Display error message if any input field has an error
      _showErrorDialog('Please correct the errors in the form:',
          usernameError: usernameError,
          emailError: emailError,
          passwordError: passwordError,
          phoneNumberError: phoneNumberError,
          addressError: addressError);
      return;
    }

    // Check if the username is unique
    bool isUsernameUnique =
        await _checkUsernameUnique(_usernameController.text);
    if (!isUsernameUnique) {
      _showErrorDialog(
          'Username is not unique. Please choose a different one.');
      return;
    }

    // All input fields are valid, proceed with adding user
    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress:$port/users'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'username': _usernameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'phone_number': _phoneNumberController.text,
          'address': _addressController.text,
          'role': int.parse(role), // Set role to 4 by default for the vendor
        }),
      );

      if (response.statusCode == 201) {
        _showSuccessDialog('User added successfully.');
      } else {
        throw Exception('Failed to add user: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Failed to add user. Please try again later.');
    }
  }

  String _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Please enter an email';
    }
    if (!value.contains('@') || !value.contains('.com')) {
      return 'Please enter a valid email address';
    }
    return 'Correct';
  }

  String _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Please enter a password';
    }
    return 'Correct';
  }

  String _validatePhoneNumber(String value) {
    if (value.isEmpty) {
      return 'Please enter a phone number';
    }
    if (value.length != 10) {
      return 'Phone number must be 10 digits';
    }
    return 'Correct';
  }

  String _validateAddress(String value) {
    if (value.isEmpty) {
      return 'Please enter an address';
    }
    return 'Correct';
  }

  Future<String> _validateUsername(String value) async {
    if (value.isEmpty) {
      return 'Please enter a username';
    }

    // Check if the username is unique
    bool isUsernameUnique = await _checkUsernameUnique(value);

    if (!isUsernameUnique) {
      return 'Username already exists. Please choose a different one.';
    }

    return 'Correct'; // Return 'Correct' if the username is unique
  }

  Future<bool> _checkUsernameUnique(String username) async {
    try {
      final response = await http.get(
        Uri.parse('http://$ipAddress:$port/users/search/name?name=$username'),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body)['exists'];
        return responseData; // Return the existence status of the username
      } else {
        throw Exception('Failed to fetch username existence status');
      }
    } catch (e) {
      print('Error fetching username existence status: $e');
      return false; // Return false to indicate failure
    }
  }

  void _showErrorDialog(String message,
      {String? usernameError,
      String? emailError,
      String? passwordError,
      String? phoneNumberError,
      String? addressError}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
                if (usernameError != null && usernameError != 'Correct')
                  Text('Username: $usernameError'),
                if (emailError != null && emailError != 'Correct')
                  Text('Email: $emailError'),
                if (passwordError != null && passwordError != 'Correct')
                  Text('Password: $passwordError'),
                if (phoneNumberError != null && phoneNumberError != 'Correct')
                  Text('Phone Number: $phoneNumberError'),
                if (addressError != null && addressError != 'Correct')
                  Text('Address: $addressError'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearTextFields();
              },
              child: const Text('OK'),
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
  }
}
