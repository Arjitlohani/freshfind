import 'package:flutter/material.dart';

void main() {
  runApp(VendorDashboard());
}

class VendorDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vendor Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VendorDashboardScreen(),
    );
  }
}

class VendorDashboardScreen extends StatefulWidget {
  @override
  _VendorDashboardScreenState createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vendor Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 54, 99, 56),
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
        return VendorHomeScreen();
      case 1:
        return Container(); // Placeholder for product management
      case 2:
        return Container(); // Placeholder for order management
      case 3:
        return Container(); // Placeholder for user management
      default:
        return Container(); // Placeholder
    }
  }
}

class VendorDrawer extends StatelessWidget {
  final Function(int) onTap;

  const VendorDrawer({required this.onTap});

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
              'Vendor Menu',
              style: TextStyle(
                color: Colors.white,
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

class VendorHomeScreen extends StatelessWidget {
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
              Expanded(child: _buildContainer('Total Products', '100')),
              Expanded(child: _buildContainer('Active Products', '50')),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildContainer('Pending Orders', '30')),
              Expanded(child: _buildContainer('Completed Orders', '20')),
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
