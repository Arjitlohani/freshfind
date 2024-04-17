import 'package:flutter/material.dart';
import 'package:freshfinds/actors/customer/checkout.dart';

import 'package:freshfinds/actors/customer/customer_dashboard.dart';
import 'package:freshfinds/actors/common/profile.dart';
import 'package:freshfinds/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  final int userId;

  CartPage({required this.userId});

  int _selectedIndex = 1; // initial index for 'Cart'

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(),
            settings: RouteSettings(arguments: {'userId': userId}),
          ),
        );
        break;
      case 1:
        // Current page, do nothing
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileScreen(userId: userId)),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart - Welcome $userId'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartProvider.cartItems.length,
              itemBuilder: (context, index) {
                return _CartItem(
                  item: cartProvider.cartItems[index],
                  onDelete: () {
                    cartProvider.removeFromCart(cartProvider.cartItems[index]);
                  },
                );
              },
            ),
          ),
          SizedBox(height: 16), // Spacer between items and total price
          Text(
            'Total Price: Rs. ${cartProvider.getTotalPrice().toStringAsFixed(2)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
              height: 16), // Spacer between total price and checkout button
          FloatingActionButton.extended(
            onPressed: () {
              // Navigate to CheckoutPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckoutPage(userId: userId),
                ),
              );
            },
            label: Text('Checkout'),
            backgroundColor: Color.fromARGB(216, 107, 231, 111),
          ),
          SizedBox(
              height:
                  16), // Spacer between checkout button and BottomNavigationBar
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightGreen,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) => _onItemTapped(index, context),
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

class _CartItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function() onDelete;

  const _CartItem({
    required this.item,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  __CartItemState createState() => __CartItemState();
}

class __CartItemState extends State<_CartItem> {
  void _incrementQuantity() {
    setState(() {
      widget.item['quantity'] = (widget.item['quantity'] ?? 1) + 1;
      Provider.of<CartProvider>(context, listen: false)
          .updateQuantity(widget.item, widget.item['quantity']);
    });
  }

  void _decrementQuantity() {
    if ((widget.item['quantity'] ?? 0) > 1) {
      setState(() {
        widget.item['quantity'] = (widget.item['quantity'] ?? 1) - 1;
        Provider.of<CartProvider>(context, listen: false)
            .updateQuantity(widget.item, widget.item['quantity']);
      });
    } else {
      setState(() {
        widget.item['quantity'] = 1;
        Provider.of<CartProvider>(context, listen: false)
            .updateQuantity(widget.item, 1);
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
              '${widget.item['quantity'] ?? 1}',
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
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }
}
