// productmmt.dart
import 'package:flutter/material.dart';

class ProductManagementScreen extends StatelessWidget {
  final List<Product> products;

  const ProductManagementScreen({Key? key, required this.products})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Management'),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product.name),
            subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Handle edit product action
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle add product action
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class Product {
  final String name;
  final double price;

  Product({required this.name, required this.price});
}
