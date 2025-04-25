import 'package:flutter/material.dart';

import '../shoppingcart.dart';

//CarrinhoScreen

class CarrinhoScreen extends StatefulWidget {
  @override
  _CarrinhoScreenState createState() => _CarrinhoScreenState();
}

class _CarrinhoScreenState extends State<CarrinhoScreen> {
  @override
  Widget build(BuildContext context) {
    double total = 0;

    for (var item in ShoppingCart.cartItems) {
      final price = item['price'];
      final quantity = item['quantity'];
      total += price * quantity;
    }

    if (ShoppingCart.cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Carrinho',
            style: TextStyle(color: Colors.blue),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Text('Carrinho vazio'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Carrinho',
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: ShoppingCart.cartItems.length,
        itemBuilder: (context, index) {
          final item = ShoppingCart.cartItems[index];
          final price = item['price'];
          final quantity = item['quantity'];

          return Card(
            child: ListTile(
              leading: Image.network(
                item['image'],
                width: 50,
                height: 50,
              ),
              title: Text(item['title']),
              subtitle: Row(
                children: [
                  Text('Preço: \$${price.toStringAsFixed(2)}'),
                  Spacer(), 
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, color: Colors.blue),
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) {
                              item['quantity']--;
                            }
                          });
                        },
                      ),
                      Text(quantity.toString()),
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          setState(() {
                            item['quantity']++;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            ShoppingCart.cartItems.removeAt(index);
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
      bottomNavigationBar: Container(
        height: 72,
        color: Colors.white,
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    ShoppingCart.cartItems.clear();
                  });
                },
                child: Text('Finalizar Compra'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
