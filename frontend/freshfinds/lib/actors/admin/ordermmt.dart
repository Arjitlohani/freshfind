// ordermmt.dart
import 'package:flutter/material.dart';

class OrderManagementScreen extends StatelessWidget {
  final List<Order> orders;

  const OrderManagementScreen({super.key, required this.orders});

  List<Order> get filteredOrders =>
      orders.where((order) => !order.isCompleted).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return ListTile(
                  title: Text('Order ID: ${order.id}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer: ${order.customerName}'),
                      Text('Items: ${order.items.join(', ')}'),
                      Text(
                          'Total Amount: \$${order.totalAmount.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Mark Completed'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Order {
  final int id;
  final String customerName;
  final List<String> items;
  final double totalAmount;
  final bool isCompleted;

  Order({
    required this.id,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    this.isCompleted = false,
  });
}
