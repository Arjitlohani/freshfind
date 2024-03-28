import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'actors/admin/admin_dashboard.dart';
import 'actors/vendor/vendor_dashboard.dart';
import 'actors/customer/customer_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        '/adminDashboard': (context) => const AdminDashboard(),
        '/vendorDashboard': (context) => const VendorDashboard(),
        '/customerDashboard': (context) => const DashboardScreen(),
        // '/driverDashboard': (context) => DriverDashboard(),
      },
    );
  }
}
