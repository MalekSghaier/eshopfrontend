import 'product.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }
}

class Cart {
  final List<CartItem> items = [];

  bool isEmpty() => items.isEmpty;
  int get totalUniqueItems => items.length;
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  void addProduct(Product product, int quantity) {
    for (var item in items) {
      if (item.product.id == product.id) {
        item.quantity += quantity;
        saveToLocal();
        return;
      }
    }
    items.add(CartItem(product: product, quantity: quantity));
    saveToLocal();
  }

  void updateProductQuantity(Product product, int quantity) {
    for (var item in items) {
      if (item.product.id == product.id) {
        if (quantity > 0) {
          item.quantity = quantity;
        } else {
          items.remove(item);
        }
        saveToLocal();
        return;
      }
    }
  }

  void removeProduct(Product product) {
    items.removeWhere((item) => item.product.id == product.id);
    saveToLocal();
  }

  void saveToLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonItems = items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('cart', jsonItems);
  }

  void loadFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonItems = prefs.getStringList('cart');
    if (jsonItems != null) {
      items.clear();
      items.addAll(jsonItems.map((jsonItem) => CartItem.fromJson(jsonDecode(jsonItem))).toList());
    }
  }
}
