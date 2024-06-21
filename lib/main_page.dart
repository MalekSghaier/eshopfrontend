
import 'package:flutter/material.dart';
import 'package:eshopfrontend/product.dart';
import 'package:eshopfrontend/api_handler.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  ApiHandler apiHandler = ApiHandler();
  List<Product> data = [];
  bool isLoading = false;
  bool isEndOfList = false;
  int pageNumber = 0;
  final int pageSize = 1000;

  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();
  Product? searchedProduct;
  String? searchError;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    getData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
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

    // Afficher les URLs dans la console
    newProducts.forEach((product) {
      print("Product ID: ${product.id}, Image URL: ${product.imageUrl}");
    });
  } catch (e) {
    // Gérer les erreurs
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
        searchError = 'Product not found or invalid ID';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
              hintText: 'Search by ID',
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
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: data.length + (isEndOfList ? 0 : 1),
                    itemBuilder: (BuildContext context, int index) {
                      if (index < data.length) {
                        return ListTile(
                          leading: data[index].imageUrl.isNotEmpty
                              ? Image.network(data[index].imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                              : Icon(Icons.image_not_supported),
                          title: Text(data[index].name),
                          subtitle: Text(data[index].description),
                        );
                      } else {
                        return _buildProgressIndicator();
                      }
                    },
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