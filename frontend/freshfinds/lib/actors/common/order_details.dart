import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:freshfinds/models/port.dart';

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

  Future<void> _postFeedback(String feedback) async {
    final url = Uri.parse('http://$ipAddress:$port/feedback');
    final response = await http.post(
      url,
      body: jsonEncode({'orderId': widget.orderId, 'feedback': feedback}),
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
                return ListTile(
                  title: Text('Products: ${item['name']}'),
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
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: feedbackController,
                  decoration: InputDecoration(
                    labelText: 'Enter Feedback',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    final feedback = feedbackController.text;
                    if (feedback.isNotEmpty) {
                      _postFeedback(feedback);
                    }
                  },
                  child: Text('Post Feedback'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                final feedback = feedbacks[index];
                return ListTile(
                  title: Text(feedback[
                      'feedback']), // Assuming the key is 'feedback' instead of 'text'
                  // You can add more details like timestamp or user info if available
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
