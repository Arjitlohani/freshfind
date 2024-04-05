import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../api/api.dart';

class ProductDisplay extends StatefulWidget {
  const ProductDisplay({Key? key}) : super(key: key);

  @override
  _ProductDisplayState createState() => _ProductDisplayState();
}

class _ProductDisplayState extends State<ProductDisplay> {
  String? _imageUrl;
  TextEditingController _productIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchProductImage(int productId) async {
    final url = Uri.parse('http://$ipAddress:$port/products/$productId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _imageUrl = responseData['imageUrl'];
        });
      } else {
        throw Exception('Failed to load product image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching product image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Image'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _productIdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter Product ID'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                int productId = int.tryParse(_productIdController.text) ?? 0;
                if (productId != 0) {
                  _fetchProductImage(productId);
                } else {
                  // Show error or handle invalid input
                }
              },
              child: Text('Search'),
            ),
            SizedBox(height: 20),
            _imageUrl != null
                ? Image.network(_imageUrl!)
                : Text('No image available'),
          ],
        ),
      ),
    );
  }
}
