import 'package:flutter/material.dart';
// Importing fl_chart library

import 'productmmt.dart';
import 'usermmt.dart';

void main() {
  runApp(const AdminDashboard());
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminDashboardScreen();
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
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
      drawer: AdminDrawer(onTap: (index) {
        setState(() {
          _currentIndex = index;
          Navigator.pop(context);
        });
      }),
      body: _buildBody(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            const Color.fromARGB(255, 54, 99, 56), // Set background color to green
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
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
        return const HomeScreen();
      case 1:
        return const ProductManagementScreen();
      case 2:
        // Call the OrderManagementScreen method here
        return Container();
      case 3:
        return const UserManagementScreen();
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

  const AdminDrawer({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
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
            title: const Text('User Management'),
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: _buildContainer('Total Orders', '100')),
            Expanded(child: _buildContainer('Dispatched Orders', '50')),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: _buildContainer('Pending Orders', '30')),
            Expanded(child: _buildContainer('Orders Delivered', '20')),
          ],
        ),
        const SizedBox(height: 20),
        // Placeholder for Pie Chart
        SizedBox(
          height: 200,
          width: MediaQuery.of(context).size.width * 0.8,
          child: const Card(
            child: Center(
              child: Text('Pie Chart Placeholder'),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Placeholder for Bar Graph
        SizedBox(
          height: 200,
          width: MediaQuery.of(context).size.width * 0.8,
          child: const Card(
            child: Center(
              child: Text('Bar Graph Placeholder'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContainer(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 54, 99, 56),
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
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
