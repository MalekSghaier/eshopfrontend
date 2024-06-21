import 'package:flutter/material.dart';
import 'main.dart';
import 'product.dart';
import 'api_handler.dart';


class ProductSearchScreen extends StatefulWidget {
  @override
  _ProductSearchScreenState createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  TextEditingController _controller = TextEditingController();
  ApiHandler apiHandler = ApiHandler();
  List<Product> filteredProducts = [];

  void _filter;
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
  }