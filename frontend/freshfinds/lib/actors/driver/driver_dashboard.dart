// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// void main() {
//   runApp(DriverDashboard());
// }

// class DriverDashboard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Driver Dashboard',
//       home: DriverDashboardScreen(),
//     );
//   }
// }

// class DriverDashboardScreen extends StatefulWidget {
//   @override
//   _DriverDashboardScreenState createState() => _DriverDashboardScreenState();
// }

// class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
//   late GoogleMapController mapController;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Driver Dashboard'),
//       ),
//       body: GoogleMap(
//         onMapCreated: _onMapCreated,
//         initialCameraPosition: CameraPosition(
//           target: LatLng(37.7749, -122.4194), // San Francisco coordinates
//           zoom: 12,
//         ),
//       ),
//     );
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }
// }
