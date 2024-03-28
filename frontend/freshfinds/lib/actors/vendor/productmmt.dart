import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ProductManagementScreen extends StatefulWidget {
  @override
  _ProductManagementScreenState createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _vendorIdController = TextEditingController();
  TextEditingController _productIdController = TextEditingController();
  String? _selectedCategory;
  String? category_id;

  List<Map<String, dynamic>> _category = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final url = Uri.parse('http://192.168.1.113:3000/category');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _category = List<Map<String, dynamic>>.from(responseData['category']);
          print(_category);
        });
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Price'),
              ),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantity'),
              ),
              TextField(
                controller: _vendorIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Vendor ID'),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                    _updateInputFieldValue(
                        newValue); // Update the category ID value
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: 'Fruits',
                    child: Text('Fruits'),
                  ),
                  DropdownMenuItem(
                    value: 'Vegetables',
                    child: Text('Vegetables'),
                  ),
                  DropdownMenuItem(
                    value: 'Beverages',
                    child: Text('Beverages'),
                  ),
                  DropdownMenuItem(
                    value: 'Dairy',
                    child: Text('Dairy'),
                  ),
                ],
                decoration: InputDecoration(labelText: 'Select Category'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: TextEditingController(text: category_id),
                enabled: false,
                decoration: InputDecoration(labelText: 'Category ID'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _addProduct(context),
                child: Text('Add Product'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _productIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Search Product by ID'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _searchProductById(context),
                child: Text('Search Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addProduct(BuildContext context) async {
    // Extracting data from text controllers
    final name = _nameController.text;
    final description = _descriptionController.text;
    final price = double.parse(_priceController.text);
    final quantity = int.parse(_quantityController.text);
    final vendorId = int.parse(_vendorIdController.text);

    // Extracting category and getting category ID
    final category = _selectedCategory;
    final categoryId = _getCategoryId(category);

    // Check if category ID is valid
    if (categoryId == 0) {
      _showErrorDialog(context, 'Please select a valid category.');
      return;
    }

    // Constructing request body
    final url = Uri.parse('http://192.168.1.113:3000/products');
    final headers = <String, String>{'Content-Type': 'application/json'};
    final body = jsonEncode({
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'vendor_id': vendorId,
      'category_id': categoryId,
    });

    try {
      // Sending POST request to add product
      final response = await http.post(url, headers: headers, body: body);

      // Checking response status code
      if (response.statusCode == 201) {
        // Show success dialog
        _showSuccessDialog(context);
      } else {
        // Show error dialog if adding product failed
        _showErrorDialog(context, 'Failed to add product.');
      }
    } catch (e) {
      // Show error dialog if request failed
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
        _showProductDetailsDialog(context, productData);
      } else {
        _showErrorDialog(context, 'Product not found.');
      }
    } catch (e) {
      _showErrorDialog(context, 'Failed to search product. Please try again.');
    }
  }

  void _showProductDetailsDialog(BuildContext context, dynamic productData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Product Details'),
          content: Text(
              'Product ID: ${productData['product_id']}\nName: ${productData['name']}\nDescription: ${productData['description']}\nPrice: ${productData['price']}\nQuantity: ${productData['quantity']}\nVendor ID: ${productData['vendor_id']}'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
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
          title: Text('Success'),
          content: Text('Product added successfully.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearTextFields();
              },
              child: Text('OK'),
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
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
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
    setState(() {
      _selectedCategory = null;
      category_id = '0';
    });
  }

  void _updateInputFieldValue(String? category) {
    setState(() {
      switch (category) {
        case 'Fruits':
          category_id = '1';
          break;
        case 'Vegetables':
          category_id = '2';
          break;
        case 'Beverages':
          category_id = '3';
          break;
        case 'Dairy':
          category_id = '4';
          break;
        default:
          category_id = '0';
      }
    });
  }

  int _getCategoryId(String? category) {
    switch (category) {
      case 'Fruits':
        return 1;
      case 'Vegetables':
        return 2;
      case 'Beverages':
        return 3;
      case 'Dairy':
        return 4;
      default:
        return 0; // Or any default category ID
    }
  }
}
