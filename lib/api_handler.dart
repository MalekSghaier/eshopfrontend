
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eshopfrontend/product.dart';

class ApiHandler {
  final String baseUrl = "http://192.168.1.244:7028/api/products";
  
  Future<List<Product>> fetchProducts(int pageNumber, int pageSize) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?pageNumber=$pageNumber&pageSize=$pageSize'));

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
      final response = await http.get(Uri.parse('$baseUrl/$id'));

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
}