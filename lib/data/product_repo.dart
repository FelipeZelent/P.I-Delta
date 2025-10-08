import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductRepo {
  ProductRepo._();
  static final instance = ProductRepo._();
  final _db = FirebaseFirestore.instance;

  // Todos (collectionGroup)
  Stream<List<Product>> streamAll({int? limit}) {
    Query<Map<String, dynamic>> q = _db.collectionGroup('items');
    if (limit != null) q = q.limit(limit);
    return q.snapshots().map((s) => s.docs.map(Product.fromDoc).toList());
  }

  // Por categoria
  Stream<List<Product>> streamByCategory(String categoryId, {int? limit}) {
    Query<Map<String, dynamic>> q =
        _db.collection('Products').doc(categoryId).collection('items');
    if (limit != null) q = q.limit(limit);
    return q.snapshots().map((s) => s.docs.map(Product.fromDoc).toList());
  }

  // Um item específico
  Future<Product> getOne(String categoryId, String pid) async {
    final doc = await _db
        .collection('Products')
        .doc(categoryId)
        .collection('items')
        .doc(pid)
        .get();
    return Product.fromDoc(doc);
  }
}
