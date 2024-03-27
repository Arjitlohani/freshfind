import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:freshfinds/actors/vendor/productmmt.dart';

void main() {
  runApp(VendorDashboard());
}

class VendorDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return VendorDashboardScreen();
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
        actions: [
          IconButton(
            icon: Icon(
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
        return VendorHomeScreen();
      case 1:
        return ProductManagementScreen(); // Placeholder for product management
      case 2:
        return Container(); // Placeholder for order management
      case 3:
        return Container(); // Placeholder for user management
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
          SizedBox(height: 20),
          // Pie Chart for Sales
          Container(
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
          SizedBox(height: 20),
          // Bar Graph for Income
          // Container(
          //   height: 200,
          //   width: MediaQuery.of(context).size.width * 0.8,
          //   child: Card(
          //     child: BarChart(
          //       BarChartData(
          //         alignment: BarChartAlignment.center,
          //         groupsSpace: 20,
          //         barTouchData: BarTouchData(enabled: false),
          //         titlesData: FlTitlesData(
          //           show: true,
          //           leftTitles: AxisTitles(
          //             show: true,
          //             getTextStyles: (value) => const TextStyle(
          //               color: Colors.black,
          //               fontWeight: FontWeight.bold,
          //               fontSize: 14,
          //             ),
          //             margin: 8,
          //             reservedSize: 32,
          //             getTitles: (value) {
          //               switch (value.toInt()) {
          //                 case 0:
          //                   return '0';
          //                 case 2:
          //                   return '20';
          //                 case 4:
          //                   return '40';
          //                 default:
          //                   return '';
          //               }
          //             },
          //           ),
          //           bottomTitles: AxisTitles(
          //             show: true,
          //             getTextStyles: (value) => const TextStyle(
          //               color: Colors.black,
          //               fontWeight: FontWeight.bold,
          //               fontSize: 14,
          //             ),
          //             margin: 8,
          //             reservedSize: 32,
          //             getTitles: (value) {
          //               switch (value.toInt()) {
          //                 case 0:
          //                   return 'A';
          //                 case 1:
          //                   return 'B';
          //                 case 2:
          //                   return 'C';
          //                 case 3:
          //                   return 'D';
          //                 default:
          //                   return '';
          //               }
          //             },
          //           ),
          //         ),
          //         borderData: FlBorderData(show: false),
          //         barGroups: [
          //           BarChartGroupData(
          //             x: 0,
          //             barsSpace: 20,
          //             barRods: [
          //               BarChartRodData(toY: 8, color: Colors.blue),
          //               BarChartRodData(toY: 10, color: Colors.green),
          //               BarChartRodData(toY: 15, color: Colors.orange),
          //               BarChartRodData(toYBarChartRodData(
          // y: 7, // the y value
          // colors: [Colors.red], // the color of the bar
          // ): 7, color: Colors.red),
          //             ],
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
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
