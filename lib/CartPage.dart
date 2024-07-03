import 'package:flutter/material.dart';
import 'package:eshopfrontend/api_handler.dart';
import 'package:eshopfrontend/cart.dart';
import 'package:eshopfrontend/OrderConfirmationPage.dart'; // Importez votre nouvelle page ici

class CartPage extends StatefulWidget {
  final Cart cart;

  const CartPage({Key? key, required this.cart}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  ApiHandler apiHandler = ApiHandler();

  void _navigateToOrderConfirmation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationPage(cart: widget.cart, totalPrice: widget.cart.totalPrice),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panier'),
        backgroundColor: Colors.teal,
      ),
      body: widget.cart.isEmpty()
          ? Center(
              child: Text(
                'Votre panier est vide',
                style: TextStyle(fontSize: 20, color: Colors.grey[600]),
              ),
            )
          : ListView.builder(
              itemCount: widget.cart.items.length,
              itemBuilder: (context, index) {
                final item = widget.cart.items[index];
                return Dismissible(
                  key: Key(item.product.id.toString()),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      widget.cart.removeProduct(item.product);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item.product.name} supprimé du panier')),
                    );
                  },
                  child: ListTile(
                    title: Row(
                      children: [
                        item.product.imageUrl.isNotEmpty
                            ? Image.network(
                                item.product.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.image_not_supported),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${item.totalPrice.toStringAsFixed(2)} dt',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (item.quantity > 1) {
                                    widget.cart.updateProductQuantity(item.product, item.quantity - 1);
                                  } else {
                                    widget.cart.removeProduct(item.product);
                                  }
                                });
                              },
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  widget.cart.updateProductQuantity(item.product, item.quantity + 1);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${widget.cart.totalPrice.toStringAsFixed(2)} dt',
                style: TextStyle(fontSize: 20),
              ),
              ElevatedButton(
                onPressed: _navigateToOrderConfirmation,
                child: Text('Commander'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
