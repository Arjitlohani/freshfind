import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freshfinds/actors/customer/addto_cart.dart';
import 'package:freshfinds/actors/customer/product_screen.dart';
import 'package:freshfinds/actors/profile.dart';
import 'package:freshfinds/api/api.dart';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _vendors = [];
  int _selectedIndex = 0;
  late int userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    userId = args?['userId'] ?? 0;
    _fetchVendors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome $userId',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 54, 99, 56),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Vendors',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _vendors.length,
              itemBuilder: (context, index) {
                final vendor = _vendors[index];
                return VendorContainer(
                  vendor: vendor,
                  onTap: () {
                    final selectedId = vendor['user_id'] as int?;
                    if (selectedId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductsScreen(
                              vendorId: selectedId, userId: userId),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightGreen,
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.white,
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
        Navigator.pushReplacementNamed(
          context,
          '/customerDashboard',
          arguments: {'userId': userId},
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CartPage(
                    cartItems: [],
                    userId: userId,
                  )),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileScreen(userId: userId)),
        );
        break;
      default:
        break;
    }
  }

  Future<void> _fetchVendors() async {
    final url = Uri.parse('http://$ipAddress:$port/vendors');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _vendors = List<Map<String, dynamic>>.from(responseData['vendors']);
        });
      } else {
        throw Exception('Failed to load vendors: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching vendors: $e');
    }
  }

  void _logout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}

class VendorContainer extends StatelessWidget {
  final Map<String, dynamic> vendor;
  final VoidCallback onTap;

  const VendorContainer({
    required this.vendor,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.0),
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          'Vendor ID: ${vendor['user_id']}',
          style: TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }
}
