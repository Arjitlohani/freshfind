import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freshfinds/actors/customer/addto_cart.dart';
import 'package:freshfinds/actors/customer/customer_dashboard.dart';
import 'package:freshfinds/api/api.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  final int? userId;

  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  bool _isEditing = false;
  int _selectedIndex = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final url = Uri.parse('http://$ipAddress:$port/users/${widget.userId}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData.isNotEmpty) {
          setState(() {
            _name = responseData['user_name'];
            _email = responseData['email'];
            _phone = responseData['phone_number'];
            _address = responseData['address'];
            _nameController.text = _name;
            _emailController.text = _email;
            _phoneController.text = _phone;
            _addressController.text = _address;
          });
        } else {
          print('No user data found');
        }
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
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
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              enabled: _isEditing,
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              enabled: _isEditing,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              enabled: _isEditing,
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
              enabled: _isEditing,
            ),
            ElevatedButton(
              onPressed: _isEditing
                  ? _saveProfile
                  : () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
              child: Text(_isEditing ? 'Save Profile' : 'Edit Profile'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightGreen,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _saveProfile() async {
    final url =
        Uri.parse('http://$ipAddress:$port/users/update/${widget.userId}');
    final Map<String, String> body = {
      'user_name': _nameController.text,
      'email': _emailController.text,
      'phone_number': _phoneController.text,
      'address': _addressController.text,
    };

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        setState(() {
          _name = _nameController.text;
          _email = _emailController.text;
          _phone = _phoneController.text;
          _address = _addressController.text;
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully')));
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update profile')));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DashboardScreen()));
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const CartPage(
                    cartItems: [],
                  )),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileScreen(userId: widget.userId)),
        );
        break;
      default:
        break;
    }
  }
}
