import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freshfinds/models/port.dart';
import 'package:http/http.dart' as http;
import 'package:freshfinds/actors/common/order_details.dart';

class AcceptedOrdersPage extends StatefulWidget {
  @override
  _AcceptedOrdersPageState createState() => _AcceptedOrdersPageState();
}

class _AcceptedOrdersPageState extends State<AcceptedOrdersPage> {
  List<dynamic> _acceptedOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAcceptedOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accepted Orders'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _acceptedOrders.isEmpty
              ? Center(child: Text('No accepted orders found'))
              : ListView.builder(
                  itemCount: _acceptedOrders.length,
                  itemBuilder: (context, index) {
                    final order = _acceptedOrders[index];

                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.all(8),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order ID: ${order['order_id']}'),
                            SizedBox(height: 8),
                            Text('Total Price: Rs. ${order['total_price']}'),
                            SizedBox(height: 8),
                            Text(
                              'Status: ${order['order_status']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('Product Count: ${order['product_count']}'),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                _updateOrderStatus(
                                    order['order_id'], 'Delivered');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 148, 213, 75),
                              ),
                              child: Text(
                                'Mark as Delivered',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _navigateToOrderDetails(order['order_id']);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 66, 165, 245),
                              ),
                              child: Text(
                                'View Details',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _fetchAcceptedOrders() async {
    final url = Uri.parse('http://$ipAddress:$port/driver/orders/accepted');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('orders')) {
          List<dynamic> orders = responseData['orders'];

          // Filter out duplicate orders based on order_id
          final uniqueOrders = <dynamic>[];
          final uniqueOrderIds = Set<int>();

          for (var order in orders) {
            if (uniqueOrderIds.add(order['order_id'])) {
              uniqueOrders.add(order);
            }
          }

          setState(() {
            _acceptedOrders = uniqueOrders;
            _isLoading = false;
          });
        } else {
          throw Exception('Unexpected response format: missing "orders" key');
        }
      } else {
        throw Exception(
            'Failed to load accepted orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching accepted orders: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateOrderStatus(int orderId, String status) async {
    final url = Uri.parse('http://$ipAddress:$port/orders/$orderId/status');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'order_status': status}),
      );

      if (response.statusCode == 200) {
        // Remove the delivered order from the local list
        setState(() {
          _acceptedOrders.removeWhere((order) => order['order_id'] == orderId);
        });
      } else {
        throw Exception(
            'Failed to update order status: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error updating order status: $e');
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
