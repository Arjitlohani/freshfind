import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freshfinds/api/api.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Import http_parser.dart for MediaType
import 'package:image_picker/image_picker.dart';

class ProductManagementScreen extends StatefulWidget {
  @override
  _ProductManagementScreenState createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  File? _imageFile; // Declare _imageFile as nullable File variable
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _vendorIdController = TextEditingController();
  TextEditingController _productIdController = TextEditingController();
  String? _selectedCategory;
  String? category_id;
  String? _imageUrl;

  List<Map<String, dynamic>> _category = [];
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _imageFile = null; // Initialize image file to null
  }

  Future<void> _fetchCategories() async {
    final url = Uri.parse('http://$ipAddress:$port/category');

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
                enabled: false, // User cannot edit vendor ID
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
                items: _category.map<DropdownMenuItem<String>>(
                    (Map<String, dynamic> category) {
                  return DropdownMenuItem<String>(
                    value: category['name'],
                    child: Text(category['name']),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Category'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: TextEditingController(text: category_id),
                enabled: false,
                decoration: InputDecoration(labelText: 'Category ID'),
              ),
              _imageFile == null
                  ? ElevatedButton(
                      onPressed: _selectImage,
                      child: Text('Select Image'),
                    )
                  : Image.file(_imageFile!), // Show selected image

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
              SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                margin: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Product ID')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Description')),
                      DataColumn(label: Text('Price')),
                      DataColumn(label: Text('Quantity')),
                      DataColumn(label: Text('Vendor ID')),
                      DataColumn(label: Text('Category ID')),
                      DataColumn(label: Text('Edit')),
                      DataColumn(label: Text('Delete')),
                    ],
                    rows: _products.map((product) {
                      return DataRow(
                        cells: [
                          DataCell(Text('${product['product_id']}')),
                          DataCell(Text('${product['name']}')),
                          DataCell(Text('${product['description']}')),
                          DataCell(Text('${product['price']}')),
                          DataCell(Text('${product['quantity']}')),
                          DataCell(Text('${product['vendor_id']}')),
                          DataCell(Text('${product['category_id']}')),
                          DataCell(
                            ElevatedButton(
                              onPressed: () => _editProduct(product),
                              child: Text('Edit'),
                            ),
                          ),
                          DataCell(
                            ElevatedButton(
                              onPressed: () => _deleteProduct(product),
                              child: Text('Delete'),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 20),
// Display the image dynamically from the URL
              _imageUrl == null
                  ? Image.asset(
                      'assets/default_image.jpg') // Display default image if URL is null
                  : Image.network(
                      'http://$ipAddress:$port/$_imageUrl',
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child; // Return the image if loading is complete
                        } else {
                          return Center(
                              child:
                                  CircularProgressIndicator()); // Display loading indicator while loading
                        }
                      },
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return Image.asset(
                            'assets/default_image.jpg'); // Display default image if error occurs
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _addProduct(BuildContext context) async {
    // Validate input fields and image selection
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _selectedCategory == null) {
      _showErrorDialog(context, 'All fields are required.');
      return;
    }

    try {
      final name = _nameController.text;
      final description = _descriptionController.text;
      final price = double.parse(_priceController.text);
      final quantity = int.parse(_quantityController.text);
      final category = _selectedCategory;
      final categoryId = _getCategoryId(category);

      final url = Uri.parse('http://$ipAddress:$port/products');
      final headers = <String, String>{'Content-Type': 'application/json'};
      final body = jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'quantity': quantity,
        'category_id': categoryId,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        // If product added successfully, upload the image
        final productId = jsonDecode(response.body)['productId'].toString();
        await _uploadImage(productId);
        _showSuccessDialog(context);
        // Clear the image field after product is added
        setState(() {
          _imageFile = null;
        });
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        final errorMessage =
            responseData['message'] ?? 'Failed to add product.';
        _showErrorDialog(context, errorMessage);
      } else {
        _showErrorDialog(context, 'Failed to add product. Please try again.');
      }
    } catch (e) {
      _showErrorDialog(context, 'Failed to add product. Please try again.');
    }
  }

  Future<void> _uploadImage(String productId) async {
    if (_imageFile == null) return;

    try {
      final url = Uri.parse('http://$ipAddress:$port/upload');
      final request = http.MultipartRequest('POST', url);
      request.fields['productId'] = productId;
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _imageFile!.path,
        contentType: MediaType('image', 'jpeg'),
      ));
      final response = await request.send();
      if (response.statusCode == 200) {
        print('Image uploaded successfully');
      } else {
        print('Failed to upload image');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  void _searchProductById(BuildContext context) async {
    if (_productIdController.text.isEmpty) {
      setState(() {
        _products.clear();
      });
    }
    final productId = int.parse(_productIdController.text);
    final url = Uri.parse('http://$ipAddress:$port/products/$productId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final productData = jsonDecode(response.body);
        // Update the _products list with the searched product details
        setState(() {
          _products = [productData];
          // Check if the product has an image URL
          if (productData.containsKey('image_url')) {
            _imageUrl = '${productData['image_url']}'; // Store the image URL
          } else {
            _imageUrl = null; // Reset _imageUrl if no image URL is found
          }
        });
      } else {
        _showErrorDialog(context, 'Product not found.');
        setState(() {
          _products.clear();
        });
      }
    } catch (e) {
      _showErrorDialog(context, 'Failed to search product. Please try again.');
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
        return 0; //  default category ID
    }
  }

  void _editProduct(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: TextEditingController(text: product['name']),
                  onChanged: (value) {
                    product['name'] = value;
                  },
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller:
                      TextEditingController(text: product['description']),
                  onChanged: (value) {
                    product['description'] = value;
                  },
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller:
                      TextEditingController(text: product['price'].toString()),
                  onChanged: (value) {
                    product['price'] = double.parse(value);
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: TextEditingController(
                      text: product['quantity'].toString()),
                  onChanged: (value) {
                    product['quantity'] = int.parse(value);
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Quantity'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Perform the update operation here
                    _updateProduct(product);
                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateProduct(Map<String, dynamic> product) async {
    try {
      final url = Uri.parse(
          'http://$ipAddress:$port/products/${product['product_id']}');
      final headers = <String, String>{'Content-Type': 'application/json'};
      final body = jsonEncode({
        'name': product['name'],
        'description': product['description'],
        'price': product['price'],
        'quantity': product['quantity'],
        'category_id': product['category_id'],
      });

      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Product updated successfully
        _showUpdateDialog(context, 'Product updated successfully.');
      } else {
        // Failed to update product
        final responseData = jsonDecode(response.body);
        final errorMessage =
            responseData['message'] ?? 'Failed to update product.';
        _showErrorDialog(context, errorMessage);
      }
    } catch (e) {
      // Error occurred while updating product
      _showErrorDialog(context, 'Failed to update product. Please try again.');
    }
  }

  void _showUpdateDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(Map<String, dynamic> product) {
    // Implement delete functionality
    // You can show a confirmation dialog and delete the product if confirmed.
    void _showDeleteDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Deleted'),
            content: Text('Product and associated image deleted successfully.'),
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

    void _deleteProduct(Map<String, dynamic> product) async {
      try {
        final productId = product['product_id'];
        final url = Uri.parse('http://$ipAddress:$port/products/$productId');

        final response = await http.delete(url);

        if (response.statusCode == 200) {
          // Product and associated image deleted successfully

          _showDeleteDialog(context);
        } else if (response.statusCode == 404) {
          // Product not found
          _showErrorDialog(context, 'Product not found.');
        } else {
          // Failed to delete product
          final responseData = jsonDecode(response.body);
          final errorMessage =
              responseData['message'] ?? 'Failed to delete product.';
          _showErrorDialog(context, errorMessage);
        }
      } catch (e) {
        // Error occurred while deleting product
        _showErrorDialog(
            context, 'Failed to delete product. Please try again.');
      }
    }
  }
}
