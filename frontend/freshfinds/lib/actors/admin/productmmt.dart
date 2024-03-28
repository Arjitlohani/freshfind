import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  _ProductManagementScreenState createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _vendorIdController = TextEditingController();
  final TextEditingController _productIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Add SingleChildScrollView to fit screen size
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              TextField(
                controller: _vendorIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Vendor ID'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _addProduct(context),
                child: const Text('Add Product'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _productIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Search Product by ID'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _searchProductById(context),
                child: const Text('Search Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addProduct(BuildContext context) async {
    final name = _nameController.text;
    final description = _descriptionController.text;
    final price = double.parse(_priceController.text);
    final quantity = int.parse(_quantityController.text);
    final vendorId = int.parse(_vendorIdController.text);

    final url = Uri.parse('http://192.168.1.113:3000/products');
    final headers = <String, String>{'Content-Type': 'application/json'};
    final body = jsonEncode({
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'vendor_id': vendorId,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        _showSuccessDialog(context);
      } else {
        _showErrorDialog(context, 'Failed to add product.');
      }
    } catch (e) {
      _showErrorDialog(context, 'Failed to add product. Please try again.');
    }
  }

  void _searchProductById(BuildContext context) async {
    final productId = int.parse(_productIdController.text);
    final url = Uri.parse('http://192.168.1.113:3000/products/$productId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final productData = jsonDecode(response.body);
        // Handle product data
        // For example, display product details in a dialog
        _showProductDetailsDialog(context, productData);
      } else {
        _showErrorDialog(context, 'Product not found.');
      }
    } catch (e) {
      _showErrorDialog(context, 'Failed to search product. Please try again.');
    }
  }

  void _showProductDetailsDialog(BuildContext context, dynamic productData) {
    // Implement dialog to display product details
    // For example:
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Product Details'),
          content: Text(
              'Product ID: ${productData['product_id']}\nName: ${productData['name']}\nDescription: ${productData['description']}\nPrice: ${productData['price']}\nQuantity: ${productData['quantity']}\nVendor ID: ${productData['vendor_id']}'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Product added successfully.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearTextFields();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _clearTextFields() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _quantityController.clear();
    _vendorIdController.clear();
    _productIdController.clear();
  }
}
