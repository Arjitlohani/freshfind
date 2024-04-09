import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freshfinds/actors/customer/addto_cart.dart';
import 'package:freshfinds/actors/customer/customer_dashboard.dart';
import 'package:freshfinds/actors/profile.dart';
import 'package:freshfinds/api/api.dart';
import 'package:http/http.dart' as http;

class ProductsScreen extends StatefulWidget {
  final int vendorId;

  const ProductsScreen({required this.vendorId, Key? key}) : super(key: key);

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _fetchProductsByVendor(widget.vendorId);
  }

  Future<void> _fetchProductsByVendor(int vendorId) async {
    final url = Uri.parse('http://$ipAddress:$port/products/vendor/$vendorId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _products = List<Map<String, dynamic>>.from(responseData);
        });
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      _cartItems.add({
        'name': product['name'],
        'description': product['description'],
        'price': product['price'],
        'image_url': product['image_url'], // Add image URL
      });
    });
    print('Product added to cart successfully: ${product['name']}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products by Vendor ${widget.vendorId}'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.75,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ProductCard(
            product: product,
            addToCart: _addToCart,
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightGreen, // Light green background color
        selectedItemColor: Colors.white, // Color of selected item
        unselectedItemColor: Colors.grey, // Color of unselected items
        currentIndex: 1, // Index of the Cart icon
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CartPage(cartItems: _cartItems)),
            );
          } else {
            // Handle other navigation items
          }
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
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>) addToCart;

  const ProductCard({
    required this.product,
    required this.addToCart,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enlarge image
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                product['image_url'] ?? '',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  product['description'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3),
                Text(
                  '\$${product['price'] ?? ''}',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Centered Add to Cart button
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  addToCart(product);
                },
                child: Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 23, 99, 37),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
