import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freshfinds/actors/customer/addto_cart.dart';
import 'package:freshfinds/actors/customer/customer_dashboard.dart';
import 'package:freshfinds/models/port.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  final int userId; // Receive userId as a parameter

  ProfileScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Define variables to store user data
  String _name = '';
  String _email = '';
  int _selectedIndex = 2; // Set the default index to 2 for Profile

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Method to fetch user data from the backend
  Future<void> _fetchUserData() async {
    final url = Uri.parse('http://$ipAddress:$port/users/${widget.userId}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Extract user data from response
        setState(() {
          _name = responseData['user_name'];
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile - Welcome ${widget.userId}'),
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

            // Update Profile Button
            ElevatedButton(
              onPressed: () {
                _updateProfile();
              },
              child: Text('Update Profile'),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigate to the appropriate page based on the tapped index
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
            builder: (context) =>
                CartPage(cartItems: [], userId: widget.userId),
          ),
        );
        break;
      case 2:
        // Navigate to profile page with userId
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

  // Method to update user profile
  void _updateProfile() {
    // Implement API call to update user profile
    // You'll need to send the updated _name and _email to the backend
  }
}
