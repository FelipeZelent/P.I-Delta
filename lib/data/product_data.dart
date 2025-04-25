import 'package:cloud_firestore/cloud_firestore.dart';

class ProductData {
  late String category;
  late String id;

  late String title;
  late String description;
  late double price;

  late List images;
  late List sizes;

  // Construtor padrão
  ProductData();

  // Construtor para carregar os dados de um documento do Firestore
  ProductData.fromDocument(DocumentSnapshot snapshot) {
    id = snapshot.id;
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    title = data["title"] ?? "Sem título";
    description = data["description"] ?? "";
    price = (data["price"] ?? 0).toDouble();
    images = List<String>.from(data["images"] ?? []);
    sizes = List<String>.from(data["sizes"] ?? []);
  }
}
