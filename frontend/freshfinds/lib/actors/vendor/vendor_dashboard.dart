import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:freshfinds/actors/common/profile.dart';
import 'package:freshfinds/actors/vendor/addDriver.dart'; // Import added
import 'package:freshfinds/actors/vendor/ordermnt.dart';
import 'package:freshfinds/actors/vendor/productmmt.dart';
import 'package:freshfinds/models/port.dart';
import 'package:freshfinds/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({Key? key}) : super(key: key);

  @override
  _VendorDashboardScreenState createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  int _currentIndex = 0;
  late int userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context);
    userId = userProvider.userId;
    print('User ID: $userId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return Text(
              'Vendor Dashboard ${userProvider.username}',
              style: const TextStyle(color: Colors.white),
            );
          },
        ),
        backgroundColor: Colors.lightGreen,
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
      drawer: VendorDrawer(onTap: (index) {
        setState(() {
          _currentIndex = index;
          Navigator.pop(context);
        });
      }),
      body: _buildBody(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightGreen,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // Set background color
        selectedItemColor: Colors.white, // Set selected item color
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Add Driver',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return VendorHomeScreen(vendorId: userId); // Pass vendorId here
      case 1:
        return ProductManagementScreen();
      case 2:
        return VendorOrderManagementPage(
          vendorId: userId,
        );
      case 3:
        return ProfileScreen(userId: userId);
      case 4:
        return DriverManagementScreen();
      default:
        return Container();
    }
  }

  void _logout(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.user = null;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}

class VendorDrawer extends StatelessWidget {
  final Function(int) onTap;

  const VendorDrawer({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.lightGreen),
            child: Text(
              'Vendor Menu',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () => onTap(0),
          ),
          ListTile(
            title: const Text('Product Management'),
            onTap: () => onTap(1),
          ),
          ListTile(
            title: const Text('Order Management'),
            onTap: () => onTap(2),
          ),
          ListTile(
            title: const Text('Profile Page'),
            onTap: () => onTap(3),
          ),
          ListTile(
            title: const Text('Add Driver'),
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class VendorHomeScreen extends StatefulWidget {
  final int vendorId;

  const VendorHomeScreen({Key? key, required this.vendorId}) : super(key: key);

  @override
  _VendorHomeScreenState createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  int totalOrders = 0;
  int placedOrders = 0;
  int acceptedOrders = 0;
  int deliveredOrders = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrderStats();
  }

  Future<void> fetchOrderStats() async {
    final url = Uri.parse(
        'http://$ipAddress:$port/vendors/${widget.vendorId}/orders/stats');
    print('Fetching order statistics for vendor ID: ${widget.vendorId}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          totalOrders = data['totalOrders'] ?? 0;
          placedOrders = data['placedOrders'] ?? 0;
          acceptedOrders = data['acceptedOrders'] ?? 0;
          deliveredOrders = data['deliveredOrders'] ?? 0;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load order statistics');
      }
    } catch (error) {
      print('Error fetching order statistics: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? CircularProgressIndicator()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildContainer('Total Orders', totalOrders.toString()),
                    _buildContainer('Placed Orders', placedOrders.toString()),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildContainer(
                        'Accepted Orders', acceptedOrders.toString()),
                    _buildContainer(
                        'Delivered Orders', deliveredOrders.toString()),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildContainer(String title, String value) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 24,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.lightGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
