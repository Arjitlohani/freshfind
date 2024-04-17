import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freshfinds/actors/common/profile.dart';
import 'package:freshfinds/actors/customer/addto_cart.dart';
import 'package:freshfinds/actors/customer/customer_dashboard.dart';
import 'package:http/http.dart' as http;
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CartPage(userId: widget.userId),
          ),
        );
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
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Orders'),
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
                      child: ListTile(
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
                            Text(
                              'Status: ${order['order_status']}',
                              style: TextStyle(
                                color: _getStatusColor(order['order_status']),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          _navigateToOrderDetails(order['order_id']);
                        },
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
    final url =
        Uri.parse('http://$ipAddress:$port/orders?customerId=${widget.userId}');
    ;

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
}

class OrderDetailsPage extends StatelessWidget {
  final int orderId;

  OrderDetailsPage({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: FutureBuilder(
        future: _fetchOrderDetails(orderId), // Pass orderId here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final orderDetails = snapshot.data as List<dynamic>?;

          if (orderDetails == null) {
            return const Center(child: Text('No order details available'));
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
    final url =
        Uri.parse('http://$ipAddress:$port/vendor/orders/$orderId/details');

    final response = await http.get(url);
    final responseData = jsonDecode(response.body);

    return responseData['order_items'];
  }
}
