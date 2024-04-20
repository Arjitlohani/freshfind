import 'package:flutter/material.dart';
import 'package:freshfinds/actors/driver/driver_dashboard.dart';
import 'package:freshfinds/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'actors/customer/customer_dashboard.dart';
import 'actors/vendor/vendor_dashboard.dart';

import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'actors/admin/admin_dashboard.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Freshfinds',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/adminDashboard': (context) => AdminDashboard(),
        '/vendorDashboard': (context) => VendorDashboardScreen(),
        '/customerDashboard': (context) => DashboardScreen(),
        '/driverDashboard': (context) => DriverDashboardPage(),
      },
    );
  }
}
