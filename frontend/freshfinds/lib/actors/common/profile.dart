import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freshfinds/actors/customer/addto_cart.dart';
import 'package:freshfinds/actors/customer/customer_dashboard.dart';
import 'package:freshfinds/models/port.dart';
import 'package:freshfinds/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final int userId; // Receive userId as a parameter

  ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _email = '';
  String _phoneNumber = '';
  String _address = '';
  bool _isEditing = false;
  int _selectedIndex = 2;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userId != null && oldWidget.userId != widget.userId) {
      _fetchUserData();
    }
  }

  Future<void> _fetchUserData() async {
    final url = Uri.parse('http://$ipAddress:$port/users/${widget.userId}');

    try {
      final response = await http.get(url);
      print(response.body);

      if (response.statusCode == 200) {
        final responseData =
            Map<String, dynamic>.from(jsonDecode(response.body));

        if (responseData.containsKey('user_name') &&
            responseData.containsKey('email') &&
            responseData.containsKey('phone_number') &&
            responseData.containsKey('address')) {
          setState(() {
            _name = responseData['user_name']?.toString() ?? 'N/A';
            _email = responseData['email']?.toString() ?? 'N/A';
            _phoneNumber = responseData['phone_number']?.toString() ?? 'N/A';
            _address = responseData['address']?.toString() ?? 'N/A';
            _nameController.text = _name;
            _emailController.text = _email;
            _phoneNumberController.text = _phoneNumber;
            _addressController.text = _address;
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching user data. Please try again later.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return Text('Profile - Welcome ${userProvider.username}');
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement photo selection logic
        },
        child: Icon(Icons.add_a_photo),
        backgroundColor: Colors.lightGreen,
        elevation: 8.0,
        tooltip: 'Add Profile Photo',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 140.0,
                height: 140.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person,
                  size: 100.0,
                  color: Colors.grey[300],
                ),
              ),
            ),
            SizedBox(height: 20.0),
            _buildTextField('Name'),
            _buildTextField('Email'),
            _buildTextField('Phone Number'),
            _buildTextField('Address'),
            SizedBox(height: 20.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_isEditing) {
                    _updateProfile();
                  } else {
                    setState(() {
                      _isEditing = true;
                    });
                  }
                },
                child: Text(_isEditing ? 'Save Profile' : 'Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  elevation: 8.0,
                  shadowColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Colors.lightGreen,
      //   selectedItemColor: Colors.white,
      //   unselectedItemColor: Colors.grey,
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.shopping_cart),
      //       label: 'Cart',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'Profile',
      //     ),
      //   ],
      // ),
    );
  }

  Widget _buildTextField(String label) {
    TextEditingController controller;

    switch (label) {
      case 'Name':
        controller = _nameController;
        break;
      case 'Email':
        controller = _emailController;
        break;
      case 'Phone Number':
        controller = _phoneNumberController;
        break;
      case 'Address':
        controller = _addressController;
        break;
      default:
        controller = TextEditingController();
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(color: Colors.lightGreen),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        readOnly: !_isEditing,
        onChanged: (newValue) {
          setState(() {
            switch (label) {
              case 'Name':
                _name = newValue;
                break;
              case 'Email':
                _email = newValue;
                break;
              case 'Phone Number':
                _phoneNumber = newValue;
                break;
              case 'Address':
                _address = newValue;
                break;
            }
          });
        },
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CartPage(userId: widget.userId),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userId: widget.userId),
          ),
        );
        break;
      default:
        break;
    }
  }

  void _updateProfile() {
    Future<void> updateUserProfile(int userId, String username, String email,
        String phoneNumber, String address) async {
      final url = Uri.parse('http://$ipAddress:$port/users/update/$userId');

      final body = {
        'user_name': username,
        'email': email,
        'phone_number': phoneNumber,
        'address': address,
      };

      try {
        final response = await http.put(
          url,
          body: jsonEncode(body),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          print('User profile updated successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User profile updated successfully'),
            ),
          );
        } else {
          print('Failed to update user profile: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to update user profile. Please try again later.'),
            ),
          );
        }
      } catch (e) {
        print('Error updating user profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error updating user profile. Please try again later.'),
          ),
        );
      }
    }

    updateUserProfile(widget.userId, _name, _email, _phoneNumber, _address);

    setState(() {
      _isEditing = false;
    });
  }
}
