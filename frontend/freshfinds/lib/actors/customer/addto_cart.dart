import 'package:flutter/material.dart';
import 'package:freshfinds/actors/customer/customer_dashboard.dart';
import 'package:freshfinds/actors/profile.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CartPage({required this.cartItems, Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int _selectedIndex = 0;
  double _totalPrice = 0.0;

  void _updateTotalPrice() {
    double total = 0.0;
    for (var item in widget.cartItems) {
      total += (item['rate'] ?? 0) * (item['quantity'] ?? 1);
    }
    setState(() {
      _totalPrice = total;
    });
  }

  @override
  void initState() {
    super.initState();
    _updateTotalPrice(); // Calculate the initial total price
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: ListView.builder(
        itemCount: widget.cartItems.length,
        itemBuilder: (context, index) {
          return CartItem(
            item: widget.cartItems[index],
            onDelete: _deleteItem,
            updateTotalPrice: _updateTotalPrice,
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightGreen,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Total: Rs. ${_totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () {
              //  order logic
            },
            label: Text(
              'Place Order',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color.fromARGB(216, 107, 231, 111),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigate to the appropriate page based on the tapped index
    switch (index) {
      case 0:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DashboardScreen()));
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        break;
      default:
        break;
    }
  }

  void _deleteItem(Map<String, dynamic> item) {
    widget.cartItems.remove(item);
    _updateTotalPrice(); // Update the total price after deleting an item
    setState(() {});
  }
}

class _CartItemState extends State<CartItem> {
  int _quantity = 1;

  void _incrementQuantity() {
    setState(() {
      _quantity++;
      widget.item['quantity'] = _quantity;
      widget.updateTotalPrice();
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        widget.item['quantity'] = _quantity;
        widget.updateTotalPrice();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: widget.item['image_url'] != null &&
              widget.item['image_url'].isNotEmpty
          ? Image.network(
              widget.item['image_url']!,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return Image.asset(
                  'assets/default_image.jpg',
                );
              },
            )
          : Image.asset(
              'assets/default_image.jpg',
            ),
      title: Text(widget.item['name'] ?? ''),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.item['description'] ?? ''),
          Text(
            'Rs. ${widget.item['rate'] ?? ''}',
            style: TextStyle(
              color: Colors.green,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: _decrementQuantity,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              '$_quantity',
              style: TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _incrementQuantity,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            color: Color.fromARGB(106, 202, 53, 42),
            onPressed: () {
              widget.onDelete(widget.item);
            },
          ),
        ],
      ),
    );
  }
}

class CartItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function(Map<String, dynamic>) onDelete;
  final VoidCallback updateTotalPrice;

  const CartItem({
    required this.item,
    required this.onDelete,
    required this.updateTotalPrice,
    Key? key,
  }) : super(key: key);

  @override
  _CartItemState createState() => _CartItemState();
}
