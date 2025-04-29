import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:suco/data/product_data.dart';
import '../tiles/product_tile.dart';

class CategoryScreen extends StatelessWidget {
  final DocumentSnapshot snapshot;

  CategoryScreen(this.snapshot);

  @override
  Widget build(BuildContext context) {
    final title = snapshot.get("title") ?? "Sem título";

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection("Products")
            .doc(snapshot.id)
            .collection("items")
            .get(),
        builder: (context, snapshotData) {
          if (!snapshotData.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var products = snapshotData.data!.docs;

          return GridView.builder(
            padding: EdgeInsets.all(4.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              childAspectRatio: 0.7,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              ProductData data = ProductData.fromDocument(products[index]);
              data.category = this.snapshot.id;
              return ProductTile("grid", data);
            },
          );
        },
      ),
    );
  }
}
