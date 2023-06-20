import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product_details.dart';

class ProdutoScreen extends StatefulWidget {
  const ProdutoScreen({Key? key}) : super(key: key);
  

  @override
  State<ProdutoScreen> createState() => _ProdutoScreenState();
}

class _ProdutoScreenState extends State<ProdutoScreen> {
  List<dynamic> products = [];
  List<String> categories = [];
  String? selectedCategory = null;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchProducts();
  }

  Future<void> fetchCategories() async {
    var url = Uri.parse('https://fakestoreapi.com/products/categories');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (mounted) {
        setState(() {
          categories = data.take(6).cast<String>().toList();
        });
      }
    } else {
      // Tratar erro na resposta da API
      print('Erro ao buscar categorias');
    }
  }

  Future<void> fetchProducts() async {
    var url = Uri.parse('https://fakestoreapi.com/products');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          products = json.decode(response.body);
        });
      }
    } else {
      // Tratar erro na resposta da API
      print('Erro ao buscar produtos');
    }
  }

  void filterProductsByCategory(String category) {
    setState(() {
      if (selectedCategory == category) {
        selectedCategory = null; // Desmarcar o filtro
      } else {
        selectedCategory = category;
      }
    });
  }

  List<dynamic> getFilteredProducts() {
    if (selectedCategory != null) {
      return products
          .where((product) => product['category'] == selectedCategory)
          .toList();
    } else {
      return products;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredProducts = getFilteredProducts();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Delta',
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.blue),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              children: [
                Container(
                  child: Text(
                    'Categorias',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  //Categoria
                  child: Container(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            filterProductsByCategory(categories[index]);
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Chip(
                              label: Text(categories[index]),
                              backgroundColor:
                                  categories[index] == selectedCategory
                                      ? Colors.blue
                                      : Colors.grey.shade200,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: filteredProducts.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetails(
                            product: filteredProducts[index],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Image.network(
                              filteredProducts[index]['image'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    filteredProducts[index]['title'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Price: \$${filteredProducts[index]['price'].toStringAsFixed(2)}',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(height: 8);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
