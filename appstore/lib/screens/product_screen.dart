import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/product_details.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<dynamic> products = [];
  List<String> categories = [];
  String? selectedCategory; // Alterado para String?

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
      setState(() {
        categories = data.take(6).cast<String>().toList();
      });
    }
  }

  Future<void> fetchProducts() async {
    var url = Uri.parse('https://fakestoreapi.com/products');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
      });
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
      body: Column(
        children: [
          Container(
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
                      backgroundColor: categories[index] == selectedCategory
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
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
            ),
          ),
        ],
      ),
    );
  }
}