import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:freshfinds/actors/common/profile.dart';
import 'package:freshfinds/actors/vendor/ordermnt.dart';
import 'package:freshfinds/actors/vendor/productmmt.dart';
import 'package:freshfinds/providers/user_provider.dart';
import 'package:provider/provider.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({Key? key}) : super(key: key);

  @override
  _VendorDashboardScreenState createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  int _currentIndex = 0;
  late int userId; // Add userId parameter

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userProvider = Provider.of<UserProvider>(context);
    userId = userProvider.userId; // Assign to class-level variable
    print('User ID: $userId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return Text(
              'Vendor Dashboard ${userProvider.userId}',
              style: TextStyle(color: Colors.white),
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
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const VendorHomeScreen();
      case 1:
        return ProductManagementScreen(); // Placeholder for product management
      case 2:
        return VendorOrderManagementPage(
          vendorId: userId,
        ); // Placeholder for order management
      case 3:
        return ProfileScreen(userId: userId); // Placeholder for user management
      default:
        return Container(); // Placeholder
    }
  }

  // Function to handle logout
  void _logout(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.user = null; // Clear the user
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
                color: Colors.white,
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
        ],
      ),
    );
  }
}

class VendorHomeScreen extends StatelessWidget {
  const VendorHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildContainer('Total Products', '19')),
              Expanded(child: _buildContainer('Active Products', '15')),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildContainer('Pending Orders', '13')),
              Expanded(child: _buildContainer('Completed Orders', '5')),
            ],
          ),
          const SizedBox(height: 20),
          // Pie Chart for Sales
          SizedBox(
            height: 200,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Card(
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 30,
                      color: Colors.blue,
                      title: 'Fruits',
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: 40,
                      color: Colors.green,
                      title: 'Vegetables',
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: 20,
                      color: Colors.orange,
                      title: 'Dairy',
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: 10,
                      color: Colors.red,
                      title: 'Beverages',
                      radius: 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainer(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 68, 210, 75),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
