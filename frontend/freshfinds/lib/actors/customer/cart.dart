import 'package:flutter/material.dart';

class Cart extends ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  void addToCart(Map<String, dynamic> item) {
    _cartItems.add(item);
    notifyListeners();
  }

  void removeFromCart(Map<String, dynamic> item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  void updateCartItemQuantity(Map<String, dynamic> item, int quantity) {
    // Implement quantity update logic here
    notifyListeners();
  }
}
