import 'package:flutter/material.dart';
import 'package:eshopfrontend/cart.dart';
import 'package:eshopfrontend/api_handler.dart';

class OrderConfirmationPage extends StatefulWidget {
  final Cart cart;
  final double totalPrice;

  const OrderConfirmationPage({Key? key, required this.cart, required this.totalPrice}) : super(key: key);

  @override
  _OrderConfirmationPageState createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  final TextEditingController _addressController = TextEditingController();
  bool _isPlacingOrder = false;

  void _placeOrder() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Veuillez saisir une adresse de livraison')));
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      ApiHandler apiHandler = ApiHandler();
      await apiHandler.placeOrder(widget.cart.items, _addressController.text, widget.totalPrice);
      widget.cart.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Commande passée avec succès!')));
      Navigator.popUntil(context, ModalRoute.withName('/'));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la passation de la commande: $e')));
      print('Order error: $e');
    } finally {
      setState(() {
        _isPlacingOrder = false;
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Confirmation de commande'),
      backgroundColor: Colors.teal,
    ),
    body: Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: widget.cart.items.length,
            itemBuilder: (context, index) {
              final item = widget.cart.items[index];
              return ListTile(
                leading: item.product.imageUrl.isNotEmpty
                    ? Image.network(item.product.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                    : Icon(Icons.image_not_supported),
                title: Text(item.product.name),
                subtitle: Text('${item.quantity} x ${item.product.price.toStringAsFixed(2)} dt'),
                trailing: Text('${item.totalPrice.toStringAsFixed(2)} dt'),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Total: ${widget.totalPrice.toStringAsFixed(2)} dt',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Adresse de livraison',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isPlacingOrder ? null : _placeOrder,
                child: _isPlacingOrder
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 10),
                          Text('Validation en cours...'),
                        ],
                      )
                    : Text('Confirmer la commande'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

}
