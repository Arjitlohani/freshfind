// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:freshfinds/models/port.dart';
// import 'package:http/http.dart' as http;

// class ResetPasswordScreen extends StatefulWidget {
//   final String username;

//   ResetPasswordScreen({required this.username});

//   @override
//   _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
// }

// class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
//   final TextEditingController newPasswordController = TextEditingController();

//   String errorMessage = '';
//   bool loading = false;

//   Future<void> resetPassword() async {
//     setState(() {
//       loading = true;
//       errorMessage = '';
//     });

//     final String url = 'http://$ipAddress:$port/reset-password';
//     final Map<String, String> headers = {'Content-Type': 'application/json'};
//     final Map<String, String> body = {
//       'username': widget.username,
//       'newPassword': newPasswordController.text,
//     };

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: headers,
//         body: jsonEncode(body),
//       );

//       if (response.statusCode == 200) {
//         // Password reset successful
//         // Navigate to login screen or display success message
//         Navigator.pop(context); // Go back to previous screen
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Password reset successful')),
//         );
//       } else {
//         setState(() {
//           errorMessage = 'Failed to reset password';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Error occurred: $e';
//       });
//     } finally {
//       setState(() {
//         loading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Reset Password'),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Reset Password for ${widget.username}',
//               style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16.0),
//             TextField(
//               controller: newPasswordController,
//               obscureText: true,
//               decoration: InputDecoration(labelText: 'New Password'),
//             ),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: loading ? null : resetPassword,
//               child: Text('Reset Password'),
//             ),
//             if (errorMessage.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: Text(
//                   errorMessage,
//                   style: TextStyle(color: Colors.red),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }