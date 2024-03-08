import 'package:flutter/material.dart';
import 'fruits.dart';
import 'vegatables.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fresh Finds Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isSearchFieldVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          _isSearchFieldVisible ? _buildSearchAppBar() : _buildRegularAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Visibility(
              visible: _isSearchFieldVisible,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                  ),
                  onFieldSubmitted: (value) {
                    // Process search query
                  },
                  onChanged: (value) {
                    setState(() {
                      _isSearchFieldVisible =
                          value.isNotEmpty; // Update search field visibility
                    });
                  },
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Explore fresh groceries and daily essentials',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 12),
            Container(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  CategoryCard(
                    title: 'Fruits',
                    icon: Icons.food_bank,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FruitsPage()),
                      );
                    },
                  ),
                  SizedBox(width: 12),
                  CategoryCard(
                    title: 'Vegetables',
                    icon: Icons.eco,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VegetablesPage()),
                      );
                    },
                  ),
                  SizedBox(width: 12),
                  CategoryCard(
                    title: 'Dairy',
                    icon: Icons.local_dining,
                    color: Colors.blue,
                    // Add onTap functionality if needed
                  ),
                  SizedBox(width: 12),
                  CategoryCard(
                    title: 'Beverages',
                    icon: Icons.local_drink,
                    color: Colors.red,
                    // Add onTap functionality if needed
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Recommended',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  RecommendedItemCard(
                    title: 'Apples',
                    image: 'assets/apple.jpg',
                    price: 'Rs. 100/kg',
                  ),
                  SizedBox(width: 12),
                  RecommendedItemCard(
                    title: 'Bananas',
                    image: 'assets/banana.jpg',
                    price: 'Rs. 60/dozen',
                  ),
                  SizedBox(width: 12),
                  RecommendedItemCard(
                    title: 'Tomatoes',
                    image: 'assets/tomato.jpg',
                    price: 'Rs. 80/kg',
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Add more content here as needed
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
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
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartScreen()),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add QR code scanner functionality
        },
        icon: Icon(Icons.qr_code),
        label: Text(''),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  AppBar _buildRegularAppBar() {
    return AppBar(
      title: Text('Fresh Finds'),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearchFieldVisible = true;
            });
          },
        ),
      ],
    );
  }

  AppBar _buildSearchAppBar() {
    return AppBar(
      title: TextFormField(
        decoration: InputDecoration(
          hintText: 'Search...',
          border: InputBorder.none,
        ),
        onFieldSubmitted: (value) {
          // Process search query
        },
        onChanged: (value) {
          setState(() {
            _isSearchFieldVisible =
                value.isNotEmpty; // Update search field visibility
          });
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            setState(() {
              _isSearchFieldVisible = false;
            });
          },
        ),
      ],
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Function()? onTap;

  const CategoryCard({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 40,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecommendedItemCard extends StatelessWidget {
  final String title;
  final String image;
  final String price;

  const RecommendedItemCard({
    required this.title,
    required this.image,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              image,
              width: 150,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            price,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // Add to cart functionality
            },
            child: Text('Add to Cart'),
          ),
        ],
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Center(
        child: Text('Cart contents will be displayed here'),
      ),
    );
  }
}
