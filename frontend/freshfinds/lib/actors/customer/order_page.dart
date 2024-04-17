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
            builder: (context) => DashboardScreen(),
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
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Price: Rs. ${order['total_price']}'),
                            Text('Status: ${order['order_status']}'),
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
        title: Text('Order Details'),
      ),
      body: FutureBuilder(
        future: _fetchOrderDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final orderDetails = snapshot.data as Map<String, dynamic>;
            return ListView.builder(
              itemCount: orderDetails['items'].length,
              itemBuilder: (context, index) {
                final item = orderDetails['items'][index];
                return ListTile(
                  title: Text('${item['product_name']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantity: ${item['quantity']}'),
                      Text('Rate: Rs. ${item['rate']}'),
                      Text('Ordered Date: ${item['ordered_date']}'),
                      Text('Delivery Date: ${item['delivery_date']}'),
                      Text('Delivery Address: ${item['delivery_address']}'),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchOrderDetails() async {
    final url = Uri.parse('http://$ipAddress:$port/orders/$orderId/details');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load order details: ${response.statusCode}');
    }
  }
}
