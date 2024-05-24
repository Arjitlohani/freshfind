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
  List<Map<String, dynamic>> _users = [];

  int _offset = 0; // Added offset variable for pagination

  @override
  void initState() {
    super.initState();
    _fetchInitialUsers(); // Call _fetchInitialUsers() to load initial data
    _userIdController.addListener(_onUserIdChanged);
    // Add listener to userIdController
  }

  @override
  void dispose() {
    _userIdController.removeListener(
        _onUserIdChanged); // Remove listener to avoid memory leaks
    super.dispose();
  }

  void _onUserIdChanged() {
    if (_userIdController.text.isEmpty) {
      _fetchInitialUsers(); // Fetch initial users when userId text field is empty
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
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
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.all(16.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search by User ID',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _fetchUser,
              child: const Text('Search'),
            ),
            const SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 200,
              margin: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('User ID')),
                      DataColumn(label: Text('Username')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Password')),
                      DataColumn(label: Text('Phone Number')),
                      DataColumn(label: Text('Role')),
                      DataColumn(label: Text('Address')),
                      DataColumn(label: Text('Edit')),
                      DataColumn(label: Text('Delete')),
                    ],
                    rows: _users.map((user) {
                      return DataRow(
                        cells: [
                          DataCell(Text('${user['user_id']}')),
                          DataCell(Text('${user['user_name']}')),
                          DataCell(Text('${user['email']}')),
                          DataCell(Text('${user['password']}')),
                          DataCell(Text('${user['phone_number']}')),
                          DataCell(Text('${user['role']}')),
                          DataCell(Text('${user['address']}')),
                          DataCell(
                            ElevatedButton(
                              onPressed: () => _editUser(user),
                              child: const Text('Edit'),
                            ),
                          ),
                          DataCell(
                            ElevatedButton(
                              onPressed: () => _deleteUser(user),
                              child: const Text('Delete'),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
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
          'role': role, // Set role to 4 by default for the vendor
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

  Future<String> _validateUsername(String value) async {
    if (value.isEmpty) {
      return 'Please enter a username';
    }

    // Check if the username is unique
    bool isUsernameUnique = await _checkUsernameUnique(value);

    if (!isUsernameUnique) {
      return 'Username is already taken';
    }

    return 'Correct';
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

  Future<bool> _checkUsernameUnique(String username) async {
    // Make an HTTP request to check if the username is unique
    final response = await http.get(
      Uri.parse('http://$ipAddress:$port/users?username=$username'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['is_unique'] != null && data['is_unique'] is bool) {
        return data['is_unique'];
      } else {
        return true; // Return false by default if is_unique is null or not a bool
      }
    } else {
      throw Exception('Failed to check username uniqueness');
    }
  }

  void _fetchUser() async {
    String userId = _userIdController.text;

    if (userId.isEmpty) {
      _showErrorDialog('Please enter a user ID');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://$ipAddress:$port/users/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _users = [data];
        });
      } else {
        throw Exception('Failed to fetch user');
      }
    } catch (e) {
      _showErrorDialog('Failed to fetch user. Please try again later.');
    }
  }

  void _fetchInitialUsers() async {
    try {
      final response = await http.get(
        Uri.parse('http://$ipAddress:$port/users?offset=$_offset'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _users = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception('Failed to fetch users');
      }
    } catch (e) {
      _showErrorDialog('Failed to fetch users. Please try again later.');
    }
  }

  void _editUser(Map<String, dynamic> user) {
    // TODO: Implement edit user functionality
  }

  void _deleteUser(Map<String, dynamic> user) async {
    try {
      final response = await http.delete(
        Uri.parse('http://$ipAddress:$port/users/${user['user_id']}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _users.remove(user);
        });
        _showSuccessDialog('User deleted successfully.');
      } else {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      _showErrorDialog('Failed to delete user. Please try again later.');
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
      builder: (context) {
        return AlertDialog(
          title: const Text('Success'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
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
}
