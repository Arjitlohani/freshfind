import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  void addToCart(Map<String, dynamic> item) {
    final existingItem = _cartItems.firstWhere(
      (cartItem) => cartItem['product_id'] == item['product_id'],
      orElse: () => <String, dynamic>{},
    );

    if (existingItem.isNotEmpty) {
      updateQuantity(existingItem, (existingItem['quantity'] ?? 1) + 1);
    } else {
      // Initialize quantity to 1 if it's not set
      item['quantity'] = item['quantity'] ?? 1;
      item['vendor_id'] = item['vendor_id'];
      _cartItems.add(item);
    }
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void removeFromCart(Map<String, dynamic> item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  void updateQuantity(Map<String, dynamic> item, int quantity) {
    final index = _cartItems.indexOf(item);
    if (index != -1) {
      _cartItems[index]['quantity'] = quantity;
      notifyListeners();
    }
  }

  double getTotalPrice() {
    double total = 0.0;
    for (var item in _cartItems) {
      // Debugging print statement
      print('Rate: ${item['rate']}, Quantity: ${item['quantity']}');

      if (item['rate'] is num && item['quantity'] is num) {
        total +=
            (double.parse(item['rate'].toString())) * (item['quantity'] ?? 1);
      } else {
        print('Invalid item: $item');
      }
    }
    return total;
  }
}
