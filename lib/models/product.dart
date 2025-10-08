import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final int priceCents;
  final List<String> images;
  final List<String> sizes;
  final String description;
  final String categoryId;

  const Product({
    required this.id,
    required this.title,
    required this.priceCents,
    required this.images,
    required this.sizes,
    required this.description,
    required this.categoryId,
  });

  String get imageUrl =>
      images.isNotEmpty ? images.first : 'https://via.placeholder.com/600x600?text=Produto';

  factory Product.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final price = data['price'];
    final cents = price is num ? (price * 100).round() : (data['priceCents'] ?? 0);

    return Product(
      id: doc.id,
      title: (data['title'] ?? '').toString(),
      priceCents: cents,
      images: (data['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      sizes: (data['sizes'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      description: (data['description'] ?? '').toString(),
      categoryId: doc.reference.parent.parent?.id ?? '',
    );
  }
}

String brl(int cents) =>
    'R\$ ${(cents / 100).toStringAsFixed(2).replaceAll('.', ',')}';
