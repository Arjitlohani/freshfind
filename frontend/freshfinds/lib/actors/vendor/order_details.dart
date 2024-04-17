import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:freshfinds/models/port.dart';

class OrderDetailsPage extends StatelessWidget {
  final int orderId;

  OrderDetailsPage({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: FutureBuilder(
        future: _fetchOrderDetails(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orderDetails = snapshot.data as List<dynamic>?;

          if (orderDetails == null) {
            return Center(child: Text('No order details available'));
          }

          return ListView.builder(
            itemCount: orderDetails.length,
            itemBuilder: (context, index) {
              final item = orderDetails[index];
              return ListTile(
                title: Text('Product: ${item['product_name']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantity: ${item['quantity']}'),
                    Text('Rate: ${item['rate']}'),
                    Text('Ordered Date: ${item['ordered_date']}'),
                    Text('Delivery Date: ${item['delivery_date']}'),
                    Text('Address: ${item['delivery_address']}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<dynamic>> _fetchOrderDetails(int orderId) async {
    final url =
        Uri.parse('http://$ipAddress:$port/vendor/orders/$orderId/details');

    final response = await http.get(url);
    final responseData = jsonDecode(response.body);

    return responseData['order_items'];
  }
}
