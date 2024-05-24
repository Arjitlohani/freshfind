// import 'package:flutter/material.dart';
// import 'package:freshfinds/models/port.dart';
// import 'package:http/http.dart' as http;

// class ResetPasswordScreen extends StatefulWidget {
//   final String email;

//   ResetPasswordScreen({required this.email});

//   @override
//   _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
// }

// class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
//   final TextEditingController _otpController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;

//   Future<void> _resetPassword() async {
//     setState(() {
//       _isLoading = true;
//     });

//     final response = await http.post(
//       Uri.parse('http://$ipAddress:$port/reset-password'),
//       body: {
//         'email': widget.email,
//         'otp': _otpController.text,
//         'newPassword': _passwordController.text,
//       },
//     );

//     setState(() {
//       _isLoading = false;
//     });

//     if (response.statusCode == 200) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Password reset successfully')),
//       );
//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error resetting password')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Reset Password')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _otpController,
//               decoration: InputDecoration(labelText: 'OTP'),
//             ),
//             TextField(
//               controller: _passwordController,
//               decoration: InputDecoration(labelText: 'New Password'),
//               obscureText: true,
//             ),
//             SizedBox(height: 20),
//             _isLoading
//                 ? CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: _resetPassword,
//                     child: Text('Reset Password'),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }
