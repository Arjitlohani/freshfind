import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freshfinds/actors/customer/customer_dashboard.dart';
import 'package:freshfinds/actors/common/profile.dart';
import 'package:freshfinds/models/port.dart';
import 'package:http/http.dart' as http;
import 'package:freshfinds/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CheckoutPage extends StatelessWidget {
  final int userId;
  final TextEditingController deliveryTimeController = TextEditingController();
  final TextEditingController deliveryAddressController =
      TextEditingController();

  CheckoutPage({required this.userId});

  Future<void> _placeOrder(
      BuildContext context, CartProvider cartProvider) async {
    final totalPrice = cartProvider.getTotalPrice();
    final orderItems = cartProvider.cartItems.map((item) {
      if (item.containsKey('product_id') && item['product_id'] != null) {
        return {
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'rate': item['rate']
        };
      } else {
        throw Exception('Missing product_id in cart item: $item');
      }
    }).toList();

    final body = jsonEncode({
      'customer_id': userId,
      'total_price': totalPrice,
      'order_status': 'Pending',
      'delivery_time': deliveryTimeController.text,
      'delivery_address': deliveryAddressController.text,
      'order_items': orderItems
    });

    final response = await http.post(
      Uri.parse('http://$ipAddress:$port/orders'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final orderId = responseData['orderId'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed successfully with ID: $orderId')),
      );

      // Clear text fields
      deliveryTimeController.clear();
      deliveryAddressController.clear();

      cartProvider.clearCart();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout - Welcome $userId'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartProvider.cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartProvider.cartItems[index];

                  return ListTile(
                    title: Text(item['name'] ?? ''),
                    subtitle: Text(
                      'Rate: Rs. ${item['rate']} | Quantity: ${item['quantity']} ',
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16), // Spacer between fields
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextFormField(
                controller: deliveryTimeController,
                decoration: InputDecoration(
                  labelText: 'Delivery Time',
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16), // Spacer between fields
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextFormField(
                controller: deliveryAddressController,
                decoration: InputDecoration(
                  labelText: 'Delivery Address',
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16), // Spacer between fields
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Total Price: Rs. ${cartProvider.getTotalPrice().toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            FloatingActionButton.extended(
              onPressed: () => _placeOrder(context, cartProvider),
              label: Text('Place Order'),
              backgroundColor: Color.fromARGB(216, 107, 231, 111),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightGreen,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: (index) {
          _onItemTapped(index, context);
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(),
            settings: RouteSettings(arguments: {'userId': userId}),
          ),
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userId: userId),
          ),
        );
        break;
      default:
        break;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Format the DateTime
        final formattedDateTime =
            DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime);

        deliveryTimeController.text = formattedDateTime;
      }
    }
  }
}
