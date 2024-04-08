import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freshfinds/actors/customer/addto_cart.dart';
import 'package:freshfinds/actors/profile.dart';
import 'package:freshfinds/api/api.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: DashboardScreen(),
  ));
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _vendors = [];
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigate to the appropriate page based on the tapped index
    switch (index) {
      case 0:
        // Navigate to home page
        // Replace 'HomePage()' with your actual home page widget
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
        break;
      case 1:
        // Navigate to cart page with dummy product data
        // You can replace this with the actual product data
        Map<String, dynamic> dummyProduct = {
          'name': 'Dummy Product',
          'price': 10.0,
          // Add other fields as needed
        };
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CartPage(product: dummyProduct)),
        );
        break;
      case 2:
        // Navigate to profile page
        // Replace 'ProfileScreen()' with your actual profile page widget
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchVendors();
  }

  Future<void> _fetchVendors() async {
    final url = Uri.parse('http://$ipAddress:$port/vendors');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _vendors = List<Map<String, dynamic>>.from(responseData['vendors']);
        });
      } else {
        throw Exception('Failed to load vendors: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching vendors: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Dashboard'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Vendors',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _vendors.length,
              itemBuilder: (context, index) {
                final vendor = _vendors[index];
                return VendorContainer(
                  vendor: vendor,
                  onTap: () {
                    final selectedId = vendor['user_id'] as int?;
                    if (selectedId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductsScreen(vendorId: selectedId),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightGreen, // Light green background color
        selectedItemColor: Colors.white, // Color of selected item
        unselectedItemColor: Colors.grey, // Color of unselected items
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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

class VendorContainer extends StatelessWidget {
  final Map<String, dynamic> vendor;
  final VoidCallback onTap;

  const VendorContainer({
    required this.vendor,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.0),
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          'Vendor ID: ${vendor['user_id']}',
          style: TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }
}

class ProductsScreen extends StatefulWidget {
  final int vendorId;

  const ProductsScreen({required this.vendorId, Key? key}) : super(key: key);

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Map<String, dynamic>> _products = [];

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
          return ProductCard(product: product);
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({required this.product, Key? key}) : super(key: key);

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
            padding: const EdgeInsets.all(0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  product['description'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
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
                  // Add to cart functionality
                  // You can implement the logic to add the product to the cart here
                },
                child: Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color.fromARGB(255, 23, 99, 37), // Button color
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
