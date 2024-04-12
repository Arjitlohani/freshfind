import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const CartPage({required this.product, Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Added ${widget.product['name']} to Cart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement your cart logic here
              },
              child: Text('View Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
