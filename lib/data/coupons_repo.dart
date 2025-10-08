import 'package:cloud_firestore/cloud_firestore.dart';

class Coupon {
  final String code;
  final int percent;
  const Coupon({required this.code, required this.percent});
}

class CouponsRepo {
  CouponsRepo._();
  static final instance = CouponsRepo._();
  final _db = FirebaseFirestore.instance;

  Future<Coupon?> getByCode(String code) async {
    final c = code.trim();
    if (c.isEmpty) return null;
    final snap = await _db.collection('coupons').doc(c.toUpperCase()).get();
    if (!snap.exists) return null;
    final data = snap.data()!;
    final p = (data['percent'] as num?)?.toInt();
    if (p == null) return null;
    return Coupon(code: snap.id, percent: p);
  }
}
