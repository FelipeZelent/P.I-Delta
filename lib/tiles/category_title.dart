import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:suco/screens/category_screen.dart';

class CategoryTitle extends StatelessWidget {
  final QueryDocumentSnapshot snapshot;

  const CategoryTitle({Key? key, required this.snapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context)=>CategoryScreen(snapshot))
          );
          print("Categoria selecionada: ${data["title"]}");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(
          data["title"] ?? "Sem título",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
