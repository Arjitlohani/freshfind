import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:freshfinds/actors/common/profile.dart';

import 'package:freshfinds/actors/customer/customer_dashboard.dart';
import '../common/order_details.dart';
import 'package:freshfinds/models/port.dart';

class ViewOrderPage extends StatefulWidget {
  final int userId;

  ViewOrderPage({required this.userId});

  @override
  _ViewOrderPageState createState() => _ViewOrderPageState();
}

class _ViewOrderPageState extends State<ViewOrderPage> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  int _selectedIndex = 1; // initial index for 'Orders'

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _onItemTapped(int index) {
    // Handle bottom navigation bar items
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
            settings: RouteSettings(arguments: {'userId': widget.userId}),
          ),
        );
        break;
      case 1:
        // Stay on the same page if 'Orders' is tapped
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileScreen(
                    userId: widget.userId,
                  )),
        );
        break;
      default:
        break;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Color.fromARGB(255, 144, 211, 67);
      case 'declined':
        return Colors.red;
      case 'placed':
        return const Color.fromARGB(255, 210, 127, 3);
      case 'pending':
        return const Color.fromARGB(255, 88, 79, 2);
      case 'delivered':
        return Color.fromARGB(255, 42, 134, 45);
      case 'returned': // Added color for returned status
        return Colors.grey; // Change to desired color
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Orders'),
        backgroundColor: Colors.lightGreen,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(child: Text('No orders found'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text('Order ID: ${order['order_id']}'),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Total Price: Rs. ${order['total_price']}'),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _showReturnConfirmationDialog(
                                        order['order_id']);
                                  },
                                  child: Text('Return'),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    textStyle: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              _navigateToOrderDetails(order['order_id']);
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Status: ${order['order_status']}',
                                style: TextStyle(
                                  color: _getStatusColor(order['order_status']),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightGreen,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Future<void> _fetchOrders() async {
    final url = Uri.parse(
        'http://$ipAddress:$port/customer/orders?customerId=${widget.userId}');

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

  void _showReturnConfirmationDialog(int orderId) {
    // Find the order with the given orderId
    var order = _orders.firstWhere((element) => element['order_id'] == orderId);

    // Check if the order status is 'Delivered'
    if (order['order_status'] == 'Delivered') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Return Order'),
            content: Text('Do you want to return this order?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _returnOrder(orderId);
                  Navigator.of(context).pop();
                },
                child: Text('Return'),
              ),
            ],
          );
        },
      );
    } else {
      // Show a message indicating that the order cannot be returned
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('The order must be delivered before it can be returned')),
      );
    }
  }

  Future<void> _updateInventory(int orderId) async {
    try {
      final url =
          Uri.parse('http://$ipAddress:$port/orders/$orderId/inventory');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print('Inventory updated successfully');
      } else {
        print('Failed to update inventory');
      }
    } catch (e) {
      print('Error updating inventory: $e');
    }
  }

  Future<void> _returnOrder(int orderId) async {
    try {
      final url = Uri.parse('http://$ipAddress:$port/orders/$orderId/status');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'order_status': 'Returned'}),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order returned successfully')),
        );

        // Update inventory after order return
        await _updateInventory(orderId);

        // Fetch updated orders
        _fetchOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to return order')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to return order')),
      );
    }
  }
}
