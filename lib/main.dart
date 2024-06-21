import 'package:flutter/material.dart';
import 'package:eshopfrontend/main_page.dart';
import 'package:eshopfrontend/product_search_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
      routes: {
        '/search': (context) => ProductSearchScreen(),
      },
    );
  }
}
