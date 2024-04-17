import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freshfinds/actors/common/order_page.dart';
import 'package:freshfinds/actors/customer/addto_cart.dart';
import 'package:freshfinds/actors/customer/product_screen.dart';
import 'package:freshfinds/actors/profile.dart';
import 'package:freshfinds/models/port.dart';
import 'package:freshfinds/providers/cart_provider.dart';
import 'package:freshfinds/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _vendors = [];
  int _selectedIndex = 0;
  late int userId;
  String? _selectedArea;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userProvider = Provider.of<UserProvider>(context);
    userId = userProvider.userId; // Assign to class-level variable
    _fetchVendors();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 54, 99, 56),
        title: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return Text(
              'Welcome ${userProvider.userId}',
              style: TextStyle(color: Colors.white),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.lightGreen,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                _navigateToDashboard();
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Cart'),
              onTap: () {
                Navigator.pop(context);
                _navigateToCart();
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                _navigateToProfile();
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag),
              title: Text('View Order'),
              onTap: () {
                Navigator.pop(context);
                _navigateToViewOrder();
              },
            ),
          ],
        ),
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
                    final selectedAddress =
                        vendor['address']?.toLowerCase() ?? '';
                    if (selectedId != null) {
                      _selectedArea = selectedAddress.contains('kathmandu')
                          ? 'Kathmandu'
                          : selectedAddress.contains('lalitpur')
                              ? 'Lalitpur'
                              : selectedAddress.contains('bhaktapur')
                                  ? 'Bhaktapur'
                                  : null;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductsScreen(
                              vendorId: selectedId,
                              userId: userId,
                              selectedArea: _selectedArea),
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

    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Navigate to the appropriate page based on the tapped index
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(),
            settings: RouteSettings(arguments: {'userId': userId}),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CartPage(userId: userId),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileScreen(
                    userId: userId,
                  )),
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
        final vendors =
            List<Map<String, dynamic>>.from(responseData['vendors']);

        // Separate vendors into different sections based on address
        List<Map<String, dynamic>> kathmanduVendors = [];
        List<Map<String, dynamic>> lalitpurVendors = [];
        List<Map<String, dynamic>> bhaktapurVendors = [];

        for (var vendor in vendors) {
          final address = vendor['address']?.toLowerCase() ?? '';

          if (address.contains('kathmandu')) {
            kathmanduVendors.add(vendor);
          } else if (address.contains('lalitpur')) {
            lalitpurVendors.add(vendor);
          } else if (address.contains('bhaktapur')) {
            bhaktapurVendors.add(vendor);
          }
        }

        // Update state with categorized vendors
        setState(() {
          _vendors = [
            if (kathmanduVendors.isNotEmpty) {'section': 'Kathmandu'},
            ...kathmanduVendors,
            if (lalitpurVendors.isNotEmpty) {'section': 'Lalitpur'},
            ...lalitpurVendors,
            if (bhaktapurVendors.isNotEmpty) {'section': 'Bhaktapur'},
            ...bhaktapurVendors,
          ];
        });
      } else {
        throw Exception('Failed to load vendors: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching vendors: $e');
    }
  }

  void _logout(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.user = null; // Clear the user
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(),
        settings: RouteSettings(arguments: {'userId': userId}),
      ),
    );
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(userId: userId),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userId: userId),
      ),
    );
  }

  void _navigateToViewOrder() {
    // Navigate to the new view order page
    // Replace the 'ViewOrderPage' with your actual view order page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewOrderPage(userId: userId),
      ),
    );
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
    if (vendor.containsKey('section')) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          vendor['section'],
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }

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
