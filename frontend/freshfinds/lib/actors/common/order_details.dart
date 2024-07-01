import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:freshfinds/models/port.dart';
import 'package:freshfinds/providers/user_provider.dart';
import 'package:provider/provider.dart';

class OrderDetailsPage extends StatefulWidget {
  final int orderId;

  OrderDetailsPage({required this.orderId});

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final TextEditingController feedbackController = TextEditingController();
  List<dynamic> orderDetails = [];
  List<dynamic> feedbacks = [];

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
    _fetchFeedbacks();
  }

  Future<void> _fetchOrderDetails() async {
    final url = Uri.parse(
        'http://$ipAddress:$port/vendor/orders/${widget.orderId}/details');
    final response = await http.get(url);
    final responseData = jsonDecode(response.body);

    setState(() {
      orderDetails = responseData['order_items'];
    });
  }

  Future<void> _fetchFeedbacks() async {
    final url =
        Uri.parse('http://$ipAddress:$port/feedbacks/${widget.orderId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData != null) {
        setState(() {
          feedbacks = responseData.reversed.toList();
        });
      } else {
        setState(() {
          feedbacks =
              []; // If no feedbacks are available, set it to an empty list
        });
      }
    } else {
      setState(() {
        feedbacks = []; // If there's an error, set it to an empty list
      });
    }
  }

  Future<void> _postFeedback(String feedback, int userRole) async {
    final url = Uri.parse('http://$ipAddress:$port/feedback');
    final response = await http.post(
      url,
      body: jsonEncode({
        'orderId': widget.orderId,
        'feedback': feedback,
        'role': userRole,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback posted successfully')),
      );
      feedbackController.clear();
      _fetchFeedbacks(); // Fetch feedbacks again to update the list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post feedback')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userRole = userProvider.userRole;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: orderDetails.length,
              itemBuilder: (context, index) {
                final item = orderDetails[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Product: ${item['name']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quantity: ${item['quantity']}'),
                        Text('Rate: ${item['rate']}'),
                        Text('Ordered Date: ${item['order_date']}'),
                        Text('Delivery Date: ${item['delivery_time']}'),
                        Text('Address: ${item['delivery_address']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(), // Visual separation between order details and feedback section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: feedbacks.length,
                    itemBuilder: (context, index) {
                      final feedback = feedbacks[index];
                      final role = feedback['role'];
                      final feedbackText = feedback['feedback'];
                      String roleText = '';

                      // Check the role and set the role text accordingly
                      if (role == 2) {
                        roleText = 'Vendor';
                      } else if (role == 3) {
                        roleText = 'Customer';
                      }

                      // Return a ListTile with the formatted feedback text
                      return ListTile(
                        title: Text(
                          // Format the feedback text with the role information
                          '$roleText: ${feedbackText}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: feedbackController,
                    decoration: InputDecoration(
                      labelText: 'Enter Feedback',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      final feedback = feedbackController.text;
                      if (feedback.isNotEmpty) {
                        _postFeedback(feedback, userRole);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(16.0),
                      elevation: 8.0,
                      backgroundColor: Colors.lightGreen, // Background color

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Text(
                      'Post Feedback',
                      style:
                          TextStyle(color: Color.fromARGB(255, 227, 224, 220)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
