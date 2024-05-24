import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freshfinds/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:freshfinds/models/port.dart';
import 'package:freshfinds/actors/common/order_details.dart';
import 'package:freshfinds/actors/driver/accept_list.dart';
import 'package:freshfinds/actors/common/profile.dart';
import 'package:provider/provider.dart';

class DriverDashboardPage extends StatefulWidget {
  @override
  _DriverDashboardPageState createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage> {
  Set<int> _uniqueOrderIds = {};
  List<dynamic> _orders = [];
  bool _isLoading = true;
  int _selectedIndex = 0;
  late int userId;

  @override
  void initState() {
    super.initState();
    _fetchPlacedOrders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userProvider = Provider.of<UserProvider>(context);
    userId = userProvider.userId; // Assign to class-level variable
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Dashboard'),
        backgroundColor: const Color.fromARGB(255, 54, 99, 56),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.lightGreen,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Orders'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AcceptedOrdersPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileScreen(userId: userId)),
                );
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(child: Text('No placed orders found'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];

                    // Display orders only with status 'Placed'
                    if (order['order_status'] != 'Placed') {
                      return SizedBox.shrink(); // Return an empty widget
                    }

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
                              Text(
                                'Status: ${order['order_status']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    width: 140,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _updateOrderStatus(
                                            order['order_id'], 'Accept');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 148, 213, 75),
                                      ),
                                      child: Text(
                                        'Accept',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 140,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _updateOrderStatus(
                                            order['order_id'], 'Reject');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Color.fromARGB(226, 197, 58, 48),
                                      ),
                                      child: Text(
                                        'Reject',
                                        style: TextStyle(color: Colors.white),
                                      ),
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
            icon: Icon(Icons.assignment),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Home screen (DriverDashboardPage)
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AcceptedOrdersPage(),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileScreen(userId: userId)),
        );
        break;
    }
  }

  void _logout(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.user = null; // Clear the user
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _fetchPlacedOrders() async {
    final url = Uri.parse('http://$ipAddress:$port/driver/orders/placed');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('orders')) {
          List<dynamic> orders = responseData['orders'];

          // Filter out duplicate orders
          orders = orders
              .where((order) => _uniqueOrderIds.add(order['order_id']))
              .toList();

          setState(() {
            _orders = orders;
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
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'order_status': status}),
      );

      if (response.statusCode == 200) {
        // Update the local orders list
        setState(() {
          _orders = _orders.map((order) {
            if (order['order_id'] == orderId) {
              order['order_status'] = status;
            }
            return order;
          }).toList();
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
