import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;
}

class Cart {
  final List<CartItem> items = [];

  bool isEmpty() {
    return items.isEmpty;
  }

  int get totalUniqueItems {
    return items.length;
  }

  void addProduct(Product product, int quantity) {
    for (var item in items) {
      if (item.product.id == product.id) {
        item.quantity += quantity;
        return;
      }
    }
    items.add(CartItem(product: product, quantity: quantity));
  }

  void updateProductQuantity(Product product, int quantity) {
    for (var item in items) {
      if (item.product.id == product.id) {
        if (quantity > 0) {
          item.quantity = quantity;
        } else {
          items.remove(item);
        }
        return;
      }
    }
  }

  void removeProduct(Product product) {
    items.removeWhere((item) => item.product.id == product.id);
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
}
