import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eshopfrontend/product.dart';
import 'package:eshopfrontend/cart.dart';

class ApiHandler {
  final String baseUrl = "http://192.168.162.214:7028/api";

  Future<List<Product>> fetchProducts(int pageNumber, int pageSize) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products?pageNumber=$pageNumber&pageSize=$pageSize'));

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        List<Product> products = body.map((dynamic item) => Product.fromJson(item)).toList();
        return products;
      } else {
        print('Failed to load products. Status code: ${response.statusCode}');
        throw Exception('Failed to load products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Error fetching products: $e');
    }
  }

  Future<Product> fetchProductById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/$id'));

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> body = json.decode(response.body);
        Product product = Product.fromJson(body);
        return product;
      } else {
        print('Failed to load product. Status code: ${response.statusCode}');
        throw Exception('Failed to load product. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching product: $e');
      throw Exception('Error fetching product: $e');
    }
  }

  Future<void> placeOrder(List<CartItem> cartItems, String address, double totalPrice) async {
    try {
      final url = Uri.parse('$baseUrl/Commandes');
      final headers = {"Content-Type": "application/json"};
      final body = jsonEncode({
        "orderDate": DateTime.now().toIso8601String(),
        "totalPrice": totalPrice,
        "deliveryAddress": address,
        "items": cartItems.map((item) => {
          "productId": item.product.id,
          "quantity": item.quantity
        }).toList()
      });

      final response = await http.post(url, headers: headers, body: body);

      print('Order response status code: ${response.statusCode}');
      print('Order response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Order placed successfully');
      } else {
        throw Exception('Failed to place order. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error placing order: $e');
      throw Exception('Error placing order: $e');
    }
  }
}
