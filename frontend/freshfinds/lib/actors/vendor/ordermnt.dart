import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freshfinds/actors/vendor/order_details.dart';
import 'package:http/http.dart' as http;
import 'package:freshfinds/models/port.dart';

class VendorOrderManagementPage extends StatefulWidget {
  final int vendorId;

  VendorOrderManagementPage({required this.vendorId});

  @override
  _VendorOrderManagementPageState createState() =>
      _VendorOrderManagementPageState();
}

class _VendorOrderManagementPageState extends State<VendorOrderManagementPage> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Management'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(child: Text('No orders received'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text('Order ID: ${order['order_id']}'),
                        subtitle: Text(
                            'Customer ID: ${order['customer_id']}\nTotal Price: Rs. ${order['total_price']}'),
                        trailing: DropdownButton<String>(
                          value: order['order_status'],
                          items: <String>['Placed', 'Dispatched', 'Pending']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            _updateOrderStatus(order['order_id'], newValue!);
                          },
                        ),
                        onTap: () {
                          _navigateToOrderDetails(order['order_id']);
                        },
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _fetchOrders() async {
    final url = Uri.parse(
        'http://$ipAddress:$port/vendor/orders?vendorId=${widget.vendorId}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        setState(() {
          _orders = responseData['orders'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching orders: $e');
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

  Future<void> _updateOrderStatus(int orderId, String status) async {
    final url = Uri.parse('http://$ipAddress:$port/orders/$orderId/status');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'order_status': status}),
    );

    if (response.statusCode == 200) {
      // Refresh the order list
      _fetchOrders();
    } else {
      // Handle error
      print('Failed to update order status: ${response.statusCode}');
    }
  }
}
