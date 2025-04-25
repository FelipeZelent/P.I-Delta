import 'package:appstore/screens/carrinho_screen.dart';
import 'package:appstore/shoppingcart.dart';
import 'package:flutter/material.dart';

class ProductDetails extends StatefulWidget {
  final dynamic product;

  const ProductDetails({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  bool isFavorite = false;
  bool isInCart = false;
  List<dynamic> cartItems = [];

  void addToCart(dynamic product) {
    setState(() {
      isInCart = true;
    });

    ShoppingCart.addItem(product);
  }

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product Details',
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.blue),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  widget.product['image'],
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 16),
              Text(
                widget.product['title'],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Category: ${widget.product['category']}',
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Price: \$${widget.product['price'].toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Description: ${widget.product['description']}',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  addToCart(widget.product);
                },
                child: Text('Add to Cart'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
