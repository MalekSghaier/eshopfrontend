import 'package:flutter/material.dart';
import 'package:eshopfrontend/cart.dart';
import 'package:eshopfrontend/main_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  final Cart cart = Cart();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Shop',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MainPage(cart: cart),
    );
  }
}
