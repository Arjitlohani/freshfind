import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  int _offset = 0; // Added offset variable for pagination

  @override
  void initState() {
    super.initState();
    _fetchInitialUsers(); // Call _fetchInitialUsers() to load initial data
    _userIdController
        .addListener(_onUserIdChanged); // Add listener to userIdController
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
            _buildTextField(_roleController, 'Role', TextInputType.number,
                (value) async {
              if (value.isEmpty) {
                return 'Please enter a role';
              }
              if (![1, 2, 3, 4].contains(int.tryParse(value))) {
                return 'Role must be 1, 2, 3, or 4';
              }
              return 'Correct';
            }),
            ElevatedButton(
              onPressed: _addUser,
              child: const Text('Add User'),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
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
    String phoneNumberError =
        _validatePhoneNumber(_phoneNumberController.text);
    String addressError = _validateAddress(_addressController.text);
    String roleError = _validateRole(_roleController.text);

    // Check if any input field has an error
    if (usernameError != 'Correct' ||
        emailError != 'Correct' ||
        passwordError != 'Correct' ||
        phoneNumberError != 'Correct' ||
        addressError != 'Correct' ||
        roleError != 'Correct') {
      // Display error message if any input field has an error
      _showErrorDialog('Please correct the errors in the form:',
          usernameError: usernameError,
          emailError: emailError,
          passwordError: passwordError,
          phoneNumberError: phoneNumberError,
          addressError: addressError,
          roleError: roleError);
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
      return 'Username is not unique. Please choose a different one.';
    }

    return 'Correct'; // Return null if the username is valid
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

  String _validateRole(String value) {
    if (value.isEmpty) {
      return 'Please enter a role';
    }
    if (![1, 2, 3, 4].contains(int.tryParse(value))) {
      return 'Role must be 1, 2, 3, or 4';
    }
    return 'Correct';
  }

  Future<bool> _checkUsernameUnique(String username) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.113:3000/users/search/name?name=$username'),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body)['users'];
        List<Map<String, dynamic>> users =
            List<Map<String, dynamic>>.from(responseData);
        return users
            .isEmpty; // Return true if the list is empty (username is unique)
      } else {
        throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch users. Please try again later.');
    }
  }

  String _validateTextField(String value) {
    if (value.isEmpty) {
      return 'This field is required';
    }
    return ''; // Return null if validation passes
  }

  void _fetchUser() async {
    try {
      // Check if the userIdController text field is empty
      if (_userIdController.text.isEmpty) {
        _fetchInitialUsers(); // If empty, fetch initial users
        return;
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.113:3000/users/${_userIdController.text}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _users = List<Map<String, dynamic>>.from(responseData);
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _users = [];
        });
        _showErrorDialog('User not found');
      } else {
        throw Exception('Failed to fetch user: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Failed to fetch user. Please try again later.');
    }
  }

  void _fetchInitialUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.113:3000/users?limit=5&offset=$_offset'),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body)['users'];
        setState(() {
          _users = List<Map<String, dynamic>>.from(responseData);
          _isLoading = false;
          _offset += 5; // Increment offset for next pagination
        });
      } else {
        throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Failed to fetch users. Please try again later.');
    }
  }

  void _editUser(Map<String, dynamic> user) async {
    TextEditingController editUsernameController = TextEditingController();
    TextEditingController editEmailController = TextEditingController();
    TextEditingController editPasswordController = TextEditingController();
    TextEditingController editPhoneNumberController = TextEditingController();
    TextEditingController editAddressController = TextEditingController();
    TextEditingController editRoleController = TextEditingController();

    _userIdController.text = user['user_id'].toString();
    editUsernameController.text = user['user_name'];
    editEmailController.text = user['email'];
    editPasswordController.text = user['password'];
    editPhoneNumberController.text = user['phone_number'];
    editAddressController.text = user['address'];
    editRoleController.text = user['role'] != null
        ? user['role'].toString()
        : ''; // Ensure role value is converted to string

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: editUsernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: editEmailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: editPasswordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                TextField(
                  controller: editPhoneNumberController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                TextField(
                  controller: editAddressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: editRoleController,
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  // Validate role value
                  if (editRoleController.text.isNotEmpty) {
                    final response = await http.put(
                      Uri.parse(
                          'http://192.168.1.113:3000/users/${user['user_id']}'),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonEncode(<String, dynamic>{
                        'username': editUsernameController.text,
                        'email': editEmailController.text,
                        'password': editPasswordController.text,
                        'phone_number': editPhoneNumberController.text,
                        'address': editAddressController.text,
                        'role': editRoleController.text,
                      }),
                    );

                    if (response.statusCode == 200) {
                      _showSuccessDialog('User updated successfully.');
                      _fetchUser();
                    } else {
                      throw Exception(
                          'Failed to update user: ${response.statusCode}');
                    }
                  } else {
                    throw Exception(
                        'Invalid role value. Please enter a valid integer.');
                  }
                } catch (e) {
                  _showErrorDialog(
                      'Failed to update user. Please try again later.');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(Map<String, dynamic> user) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: const Text('Are you sure you want to delete this user?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  final response = await http.delete(
                    Uri.parse(
                        'http://192.168.1.113:3000/users/${user['user_id']}'),
                  );

                  if (response.statusCode == 200) {
                    _showSuccessDialog('User deleted successfully.');
                    _fetchUser();
                  } else {
                    throw Exception(
                        'Failed to delete user: ${response.statusCode}');
                  }
                } catch (e) {
                  _showErrorDialog(
                      'Failed to delete user. Please try again later.');
                }
              },
              child: const Text('Delete'),
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

  void _showErrorDialog(String message,
      {String? usernameError,
      String? emailError,
      String? passwordError,
      String? phoneNumberError,
      String? addressError,
      String? roleError}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (usernameError != null) Text(usernameError),
              if (emailError != null) Text(emailError),
              if (passwordError != null) Text(passwordError),
              if (phoneNumberError != null) Text(phoneNumberError),
              if (addressError != null) Text(addressError),
              if (roleError != null) Text(roleError),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
    _roleController.clear();
  }
}
