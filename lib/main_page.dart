import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:eshopfrontend/CartPage.dart';
import 'package:eshopfrontend/cart.dart';
import 'package:eshopfrontend/product.dart';
import 'package:eshopfrontend/api_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  final Cart cart;

  const MainPage({Key? key, required this.cart}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  ApiHandler apiHandler = ApiHandler();
  List<Product> data = [];
  bool isLoading = false;
  bool isEndOfList = false;
  int pageNumber = 0;
  final int pageSize = 20;
  Map<int, int> quantities = {};

  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();
  Product? searchedProduct;
  String? searchError;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    getData();
    widget.cart.loadFromLocal();
    _updateCartNotification();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  

 
  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !isEndOfList) {
      getData();
    }
  }

  void getData() async {
    if (isLoading || isEndOfList) return;

    setState(() {
      isLoading = true;
    });

    try {
      final newProducts = await apiHandler.fetchProducts(pageNumber, pageSize);
      setState(() {
        if (newProducts.isEmpty) {
          isEndOfList = true;
        } else {
          data.addAll(newProducts);
          pageNumber++;
        }
      });

      newProducts.forEach((product) {
        print("Product ID: ${product.id}, Image URL: ${product.imageUrl}");
      });
    } catch (e) {
      // Handle errors
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void searchProductById() async {
    setState(() {
      searchedProduct = null;
      searchError = null;
      isLoading = true;
    });

    try {
      int id = int.parse(_searchController.text);
      final product = await apiHandler.fetchProductById(id);
      setState(() {
        searchedProduct = product;
      });
    } catch (e) {
      setState(() {
        searchError = 'Produit non trouvé ou ID incorrect ';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void addToCart(Product product, int quantity) {
    setState(() {
      widget.cart.addProduct(product, quantity);
      _updateCartNotification();
    });
  }

  void removeFromCart(Product product) {
    setState(() {
      widget.cart.removeProduct(product);
      _updateCartNotification();
    });
  }

  void _updateCartNotification() {
    setState(() {
      // Mettre à jour la notification en fonction du nombre de produits restants dans le panier
      // Vous pouvez utiliser widget.cart.totalUniqueItems pour obtenir le nombre de produits uniques dans le panier
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Produits eShop"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher selon ID',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: searchProductById,
                ),
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (value) => searchProductById(),
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : searchedProduct != null
              ? ListTile(
                  leading: searchedProduct!.imageUrl.isNotEmpty
                      ? Image.network(searchedProduct!.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.image_not_supported),
                  title: Text(searchedProduct!.name),
                  subtitle: Text(searchedProduct!.description),
                )
              : searchError != null
                  ? Center(child: Text(searchError!))
                  : GridView.builder(
                      controller: _scrollController,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3 / 4,
                      ),
                      itemCount: data.length + (isEndOfList ? 0 : 1),
                      itemBuilder: (BuildContext context, int index) {
                        if (index < data.length) {
                          final product = data[index];
                          final quantity = quantities[product.id] ?? 1;
                          return Card(
                            child: Column(
                              children: [
                                Expanded(
                                  child: product.imageUrl.isNotEmpty
                                      ? Image.network(product.imageUrl, fit: BoxFit.cover)
                                      : Icon(Icons.image_not_supported, size: 50),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(product.name),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(product.description),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () {
                                        setState(() {
                                          if (quantity > 1) {
                                            quantities[product.id] = quantity - 1;
                                          }
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      width: 40,
                                      child: TextField(
                                        controller: TextEditingController(
                                          text: quantity.toString(),
                                        ),
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          setState(() {
                                            int newQuantity = int.tryParse(value) ?? 1;
                                            if (newQuantity > 0) {
                                              quantities[product.id] = newQuantity;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                          quantities[product.id] = quantity + 1;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    addToCart(product, quantity);
                                  },
                                  child: Text('Add to Cart'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return _buildProgressIndicator();
                        }
                      },
                    ),
      floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage(cart: widget.cart)),
              ).then((value) {
                setState(() {
                  _updateCartNotification();
                });
              });
            },
            child: Icon(Icons.shopping_cart),
            backgroundColor: Colors.teal,
          ),
          Positioned(
            right: 0,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Text(
                '${widget.cart.totalUniqueItems}',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: isLoading ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
