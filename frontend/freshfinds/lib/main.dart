import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'actors/admin/admin_dashboard.dart';
import 'actors/vendor/vendor_dashboard.dart';
import 'actors/customer/customer_dashboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freshfinds',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/adminDashboard': (context) => AdminDashboard(),
        '/vendorDashboard': (context) => VendorDashboard(),
        '/customerDashboard': (context) => DashboardScreen(),
        // '/driverDashboard': (context) => DriverDashboard(),
      },
    );
  }
}
