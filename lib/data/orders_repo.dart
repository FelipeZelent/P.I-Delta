import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'cart_repo.dart';

class OrderItem {
  OrderItem({required this.title, required this.priceDouble, required this.size, required this.qty, required this.image});
  final String title;
  final double priceDouble;
  final String size;
  final int qty;
  final String image;
}

class OrderModel {
  OrderModel({required this.id, required this.createdAt, required this.status, required this.items, required this.totalPrice});
  final String id;
  final DateTime createdAt;
  final int status;
  final List<OrderItem> items;
  final double totalPrice;
}

class OrdersRepo {
  OrdersRepo._();
  static final instance = OrdersRepo._();
  final _db = FirebaseFirestore.instance;

  Stream<List<OrderModel>> streamByUser(String uid) {
    return _db
        .collection('orders')
        .where('clientId', isEqualTo: uid)
        .snapshots()
        .map((s) {
      final list = s.docs.map(_fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  OrderModel _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data()!;
    final items = ((data['products'] ?? []) as List).map((e) {
      final prod = (e['product'] ?? {}) as Map<String, dynamic>;
      return OrderItem(
        title: (prod['title'] ?? '').toString(),
        priceDouble: (prod['price'] as num?)?.toDouble() ?? 0.0,
        size: (prod['size'] ?? '').toString(),
        qty: (prod['quantity'] as num?)?.toInt() ?? 1,
        image: (prod['image'] ?? '').toString(),
      );
    }).toList();

    return OrderModel(
      id: d.id,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: (data['status'] as num?)?.toInt() ?? 1,
      items: items,
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Future<void> checkout({
    required String uid,
    required List<CartLine> lines,
    String? couponCode,
    int? discountPercent,
  }) async {
    final products = lines.map((l) {
      return {
        'category': l.product.categoryId,
        'pid': l.product.id,
        'product': {
          'title': l.product.title,
          'description': l.product.description,
          'price': l.product.priceCents / 100.0,
          'image': l.product.imageUrl,
          'quantity': l.qty,
          'size': l.size,
        }
      };
    }).toList();

    final totalBefore = lines.fold<double>(0.0, (s, l) => s + (l.product.priceCents / 100.0) * l.qty);
    final percent = (discountPercent ?? 0).clamp(0, 100);
    final discountValue = totalBefore * (percent / 100.0);
    final totalAfter = (totalBefore - discountValue).clamp(0.0, double.infinity);

    final ref = _db.collection('orders').doc();
    final batch = _db.batch();

    batch.set(ref, {
      'clientId': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'products': products,
      'productsPrice': totalBefore,
      'couponCode': couponCode,
      'discountPercent': percent,
      'discountValue': discountValue,
      'totalPrice': totalAfter,
      'status': 1,
    });

    final cartCol = _db.collection('users').doc(uid).collection('cart');
    final cartSnap = await cartCol.get();
    for (final d in cartSnap.docs) {
      batch.delete(d.reference);
    }

    await batch.commit();
  }
}
