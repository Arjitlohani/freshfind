import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freshfinds/Api/api.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

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
  String? _selectedCategory;
  String? category_id;

  List<Map<String, dynamic>> _category = [];
  late File _image;

  @override
  void initState() {
    super.initState();
    _image = File(''); // Initialize _image with a default value
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    // Simulated data fetching
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _category = [
        {"name": "Fruits"},
        {"name": "Vegetables"},
        {"name": "Beverages"},
        {"name": "Dairy"},
      ];
    });
  }

  // Modify _uploadImage function to correctly update _image variable
  Future<void> _uploadImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _image = File(result.files.single.path!);
      });
    } else {
      // User canceled the picker
      print('User canceled image selection.');
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
                    _updateInputFieldValue(newValue);
                  });
                },
                items: _category.map<DropdownMenuItem<String>>((category) {
                  return DropdownMenuItem<String>(
                    value: category['name'],
                    child: Text(category['name']),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Category'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _uploadImage(),
                child: Text('Upload Image'),
              ),
              SizedBox(height: 20),
              if (_image != null) // Conditionally check if _image is not null
                Image.file(
                  _image,
                  height: 250,
                  width: 50,
                  fit: BoxFit.cover,
                )
              else
                Container(), // Placeholder container if _image is null
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _addProduct(context),
                child: Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addProduct(BuildContext context) async {
    // Validate input fields
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _vendorIdController.text.isEmpty ||
        _selectedCategory == null ||
        _image == null) {
      _showErrorDialog(context, 'All fields are required.');
      return;
    }

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

    // Create multipart request for image upload
    final url = Uri.parse('http://$ipAddress:$port/products');
    final request = http.MultipartRequest('POST', url);

    // Add fields to multipart request
    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    request.fields['quantity'] = quantity.toString();
    request.fields['vendor_id'] = vendorId.toString();
    request.fields['category_id'] = categoryId.toString();

    // Add image file to multipart request
    final imageFile = await http.MultipartFile.fromPath('image', _image.path);
    request.files.add(imageFile);

    try {
      // Send POST request with multipart data to add product
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Check response status code
      if (response.statusCode == 201) {
        // Show success dialog
        _showSuccessDialog(context);
      } else if (response.statusCode == 400) {
        // Bad request - Display error message from server
        final responseData = jsonDecode(response.body);
        final errorMessage =
            responseData['message'] ?? 'Failed to add product.';
        _showErrorDialog(context, errorMessage);
      } else {
        // Show generic error message if adding product failed
        _showErrorDialog(context, 'Failed to add product. Please try again.');
      }
    } catch (e) {
      // Show error dialog if request failed
      _showErrorDialog(context, 'Failed to add product. Please try again.');
    }
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
    setState(() {
      _selectedCategory = null;
      category_id = '0';
      _image = File('');
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
