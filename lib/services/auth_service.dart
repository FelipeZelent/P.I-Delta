import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // ---- estado ----
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;

  Future<String> getOrCreateUid() async {
    try {
      final u = _auth.currentUser ?? (await _auth.signInAnonymously()).user;
      return u!.uid;
    } catch (_) {
      return 'guest'; // fallback só para testes
    }
  }

  Future<void> signOut() => _auth.signOut();

  // ---- LOGIN ----
  Future<UserCredential> signInEmailPassword(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _ensureUserDoc(cred.user!);
      return cred;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // opcional: criar conta automaticamente se desejar
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await cred.user!.updateDisplayName(email.split('@').first);
        await _ensureUserDoc(cred.user!);
        return cred;
      }
      rethrow;
    }
  }

  // ---- SIGNUP ----
  Future<UserCredential> signUpEmailPassword({
    required String email,
    required String password,
    String? name,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (name != null && name.trim().isNotEmpty) {
      await cred.user!.updateDisplayName(name.trim());
    } else {
      await cred.user!.updateDisplayName(email.split('@').first);
    }
    await _ensureUserDoc(cred.user!);
    return cred;
  }

  // ---- RESET PASSWORD ----
  Future<void> sendPasswordReset({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ---- PROFILE ----
  Future<void> updateProfile({required String name}) async {
    final u = _auth.currentUser;
    if (u == null) return;
    await u.updateDisplayName(name);
    await _db.collection('users').doc(u.uid).set({
      'name': name,
      'email': u.email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _ensureUserDoc(User u) async {
    final ref = _db.collection('users').doc(u.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'name': u.displayName ?? '',
        'email': u.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
