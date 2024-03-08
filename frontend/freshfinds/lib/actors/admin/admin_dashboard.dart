import 'package:flutter/material.dart';

import 'productmmt.dart';
import 'usermmt.dart';

void main() {
  runApp(AdminDashboard());
}

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      home: AdminDashboardScreen(),
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 54, 99, 56),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: AdminDrawer(onTap: (index) {
        setState(() {
          _currentIndex = index;
          Navigator.pop(context);
        });
      }),
      body: _buildBody(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            Color.fromARGB(255, 54, 99, 56), // Set background color to green
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Users',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return HomeScreen();
      case 1:
        return ProductManagementScreen(products: []);
      case 2:
      // Call the OrderManagementScreen method here
      // return OrderManagementScreen(orders: []);
      case 3:
        return UserManagementScreen(users: []);
      default:
        return Container(); // Placeholder
    }
  }

  // Function to handle logout
  void _logout(BuildContext context) {
    // Perform any necessary logout tasks here
    // For example, clearing authentication tokens or session data
    // Navigate back to the login screen
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}

class AdminDrawer extends StatelessWidget {
  final Function(int) onTap;

  const AdminDrawer({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 54, 99, 56),
            ),
            child: Text(
              'Admin Menu',
              style: TextStyle(
                color: Color.fromARGB(255, 249, 250, 249),
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Home'),
            onTap: () => onTap(0),
          ),
          ListTile(
            title: Text('Product Management'),
            onTap: () => onTap(1),
          ),
          ListTile(
            title: Text('Order Management'),
            onTap: () => onTap(2),
          ),
          ListTile(
            title: Text('User Management'),
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
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
              Expanded(child: _buildContainer('Total Orders', '100')),
              Expanded(child: _buildContainer('Dispatched Orders', '50')),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildContainer('Pending Orders', '30')),
              Expanded(child: _buildContainer('Orders Delivered', '20')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContainer(String title, String value) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 54, 99, 56),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
