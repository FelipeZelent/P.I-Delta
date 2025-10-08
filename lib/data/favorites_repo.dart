import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'product_repo.dart';

class FavoritesRepo {
  FavoritesRepo._();
  static final instance = FavoritesRepo._();
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('favorites');

  String _docId(String categoryId, String pid) => '${categoryId}_$pid';

  Future<void> toggle(String uid, Product p) async {
    final ref = _col(uid).doc(_docId(p.categoryId, p.id));
    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'category': p.categoryId,
        'pid': p.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Stream das chaves (category/pid)
  Stream<List<({String category, String pid})>> streamKeys(String uid) {
    return _col(uid).orderBy('createdAt', descending: true).snapshots().map(
      (s) => s.docs
          .map((d) => (category: d.data()['category'] as String, pid: d.data()['pid'] as String))
          .toList(),
    );
  }

  /// Stream dos produtos favoritados
  Stream<List<Product>> streamProducts(String uid) {
    return streamKeys(uid).asyncMap((keys) async {
      final futures = keys.map((k) => ProductRepo.instance.getOne(k.category, k.pid));
      return Future.wait(futures);
    });
  }

  /// Stream booleana: se um produto está favoritado
  Stream<bool> isFav(String uid, Product p) {
    return _col(uid).doc(_docId(p.categoryId, p.id)).snapshots().map((d) => d.exists);
  }
}
