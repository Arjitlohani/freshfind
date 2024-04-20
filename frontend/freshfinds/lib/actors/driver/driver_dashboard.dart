import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freshfinds/models/port.dart';
import 'package:http/http.dart' as http;

class DriverDashboardPage extends StatefulWidget {
  @override
  _DriverDashboardPageState createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlacedOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Dashboard'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(child: Text('No placed orders found'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.all(8),
                      child: InkWell(
                        onTap: () {
                          _navigateToOrderDetails(order['order_id']);
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order ID: ${order['order_id']}'),
                              SizedBox(height: 8),
                              Text('Total Price: Rs. ${order['total_price']}'),
                              SizedBox(height: 8),
                              Text('Status: ${order['order_status']}'),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _updateOrderStatus(
                                          order['order_id'], 'Accepted');
                                    },
                                    child: Text('Accepted'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightGreen,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _updateOrderStatus(
                                          order['order_id'], 'Declined');
                                    },
                                    child: Text('Declined'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // Update _fetchPlacedOrders method
  Future<void> _fetchPlacedOrders() async {
    final url = Uri.parse('http://$ipAddress:$port/driver/orders/placed');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('orders')) {
          setState(() {
            _orders = responseData['orders'];
            _isLoading = false;
          });
        } else {
          throw Exception('Unexpected response format: missing "orders" key');
        }
      } else {
        throw Exception('Failed to load placed orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching placed orders: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateOrderStatus(int orderId, String status) async {
    final url = Uri.parse('http://$ipAddress:$port/orders/$orderId/status');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('orders')) {
          setState(() {
            _orders = responseData['orders'];
            _isLoading = false;
          });
        } else {
          throw Exception('Unexpected response format: missing "orders" key');
        }
      } else {
        throw Exception(
            'Failed to load placed orders: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error fetching placed orders: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToOrderDetails(int orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsPage(orderId: orderId),
      ),
    );
  }
}

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
          } else if (snapshot.hasError) {
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
          );
        },
      ),
    );
  }

  Future<List<dynamic>> _fetchOrderDetails(int orderId) async {
    final url = Uri.parse('http://$ipAddress:$port/orders/$orderId/details');

    final response = await http.get(url);
    final responseData = jsonDecode(response.body);

    return responseData['order_items'];
  }
}
