import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freshfinds/models/port.dart';
import 'package:http/http.dart' as http;

class OrderManagementScreen extends StatefulWidget {
  @override
  _OrderManagementScreenState createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final url = Uri.parse('http://$ipAddress:$port/orders');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Management'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(child: Text('No orders found'))
              : SingleChildScrollView(
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Order ID')),
                      DataColumn(label: Text('Order Status')),
                      DataColumn(label: Text('Total Price')),
                    ],
                    rows: _orders.map((order) {
                      return DataRow(
                        cells: [
                          DataCell(Text('${order['order_id']}')),
                          DataCell(Text('${order['order_status']}')),
                          DataCell(Text('Rs. ${order['total_price']}')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
    );
  }
}
