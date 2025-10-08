import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'product_repo.dart';

class CartRepo {
  CartRepo._();
  static final instance = CartRepo._();
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('cart');

  String _docId(String categoryId, String pid, String size) =>
    '${categoryId}_${pid}_$size';

  Future<void> addOrInc({
    required String uid,
    required Product product,
    required String size,
    int qty = 1,
  }) async {
    final ref = _col(uid).doc(_docId(product.categoryId, product.id, size));
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.exists) {
        final cur = (snap.data()!['qty'] as num?)?.toInt() ?? 1;
        tx.update(ref, {'qty': cur + qty});
      } else {
        tx.set(ref, {
          'category': product.categoryId,
          'pid': product.id,
          'size': size,
          'qty': qty,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> updateQty({
    required String uid,
    required Product product,
    required String size,
    required int qty,
  }) async {
    final ref = _col(uid).doc(_docId(product.categoryId, product.id, size));
    if (qty <= 0) {
      await ref.delete();
    } else {
      await ref.update({'qty': qty});
    }
  }

  Future<void> remove({
    required String uid,
    required Product product,
    required String size,
  }) async {
    final ref = _col(uid).doc(_docId(product.categoryId, product.id, size));
    await ref.delete();
  }

  Stream<List<CartLine>> streamLines(String uid) {
    return _col(uid).orderBy('addedAt', descending: true).snapshots().asyncMap(
      (s) async {
        final futures = s.docs.map((d) async {
          final data = d.data();
          final cat = data['category'] as String;
          final pid = data['pid'] as String;
          final size = data['size'] as String;
          final qty = (data['qty'] as num).toInt();
          final product = await ProductRepo.instance.getOne(cat, pid);
          return CartLine(product: product, size: size, qty: qty);
        });
        return Future.wait(futures);
      },
    );
  }
}

class CartLine {
  CartLine({required this.product, required this.size, required this.qty});
  final Product product;
  final String size;
  final int qty;

  int get lineTotalCents => product.priceCents * qty;
}
