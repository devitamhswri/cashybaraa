import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart'; // ← Ditambahkan

class FirebaseService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(); // ← Ditambahkan

  // ── AUTH ──────────────────────────────────────────────────────────────────

  static Future<String?> register(
      String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final uid = cred.user!.uid;

      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'created_at': FieldValue.serverTimestamp(),
      });

      await _createDefaultCategories(uid);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return 'Email sudah terdaftar';
      if (e.code == 'weak-password') return 'Password minimal 6 karakter';
      return 'Registrasi gagal';
    }
  }

  static Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'Email tidak ditemukan';
      if (e.code == 'wrong-password') return 'Password salah';
      return 'Login gagal';
    }
  }

  // Method Login dengan Google
  static Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Login dibatalkan';

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      // Simpan nama user ke Firestore kalau user baru
      if (userCredential.additionalUserInfo?.isNewUser == true && user != null) {
        await _db.collection('users').doc(user.uid).set({
          'name': user.displayName ?? 'User',
          'email': user.email ?? '',
          'created_at': FieldValue.serverTimestamp(),
        });
        
        // Membuat kategori default untuk user baru dari Google login
        await _createDefaultCategories(user.uid);
      }
      return null; // sukses
    } catch (e) {
      return 'Google Sign-In gagal: $e';
    }
  }

  static Future<void> logout() async => await _auth.signOut();

  // Method Sign Out Google
  static Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  static User? get currentUser => _auth.currentUser;
  static String? get uid => _auth.currentUser?.uid;
  static bool get isLoggedIn => _auth.currentUser != null;

  // ── USER ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getUser() async {
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  // ── CATEGORIES ────────────────────────────────────────────────────────────

  static Future<void> _createDefaultCategories(String userId) async {
    final defaults = [
      {'name': 'Makanan & Minuman', 'icon': '🍔', 'color': '#F4A03A', 'bg_color': '#FFF3E0', 'type': 'expense'},
      {'name': 'Transportasi',      'icon': '🚗', 'color': '#42A5F5', 'bg_color': '#E3F2FD', 'type': 'expense'},
      {'name': 'Biaya Utilitas',    'icon': '🏠', 'color': '#66BB6A', 'bg_color': '#E8F5E9', 'type': 'expense'},
      {'name': 'Belanja',           'icon': '🛍', 'color': '#EC407A', 'bg_color': '#FCE4EC', 'type': 'expense'},
      {'name': 'Kesehatan',         'icon': '❤️', 'color': '#EF5350', 'bg_color': '#FDF3E7', 'type': 'expense'},
      {'name': 'Perawatan',         'icon': '💆', 'color': '#AB47BC', 'bg_color': '#F3E5F5', 'type': 'expense'},
      {'name': 'Gaji',              'icon': '💼', 'color': '#26A69A', 'bg_color': '#E0F2F1', 'type': 'income'},
    ];
    final batch = _db.batch();
    for (final cat in defaults) {
      final ref = _db.collection('users').doc(userId).collection('categories').doc();
      batch.set(ref, {...cat, 'created_at': FieldValue.serverTimestamp()});
    }
    await batch.commit();
  }

  static Future<List<Map<String, dynamic>>> getCategories({String? type}) async {
    if (uid == null) return [];
    Query query = _db.collection('users').doc(uid).collection('categories');
    if (type != null) query = query.where('type', isEqualTo: type);
    final snap = await query.get();
    return snap.docs
        .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
        .toList();
  }

  static Future<String> addCategory(Map<String, dynamic> data) async {
    final ref = await _db
        .collection('users').doc(uid).collection('categories')
        .add({...data, 'created_at': FieldValue.serverTimestamp()});
    return ref.id;
  }

  static Future<void> deleteCategory(String categoryId) async {
    await _db.collection('users').doc(uid).collection('categories').doc(categoryId).delete();
  }

  // ── ACCOUNTS ──────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getAkun() async {
    if (uid == null) return [];
    final snap = await _db
        .collection('users').doc(uid).collection('accounts')
        .orderBy('created_at')
        .get();
    return snap.docs
        .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
        .toList();
  }

  static Future<String> addAkun(Map<String, dynamic> data) async {
    final ref = await _db
        .collection('users').doc(uid).collection('accounts')
        .add({...data, 'created_at': FieldValue.serverTimestamp()});
    return ref.id;
  }

  static Future<void> updateSaldoAkun(String akunId, int saldoBaru) async {
    await _db
        .collection('users').doc(uid).collection('accounts')
        .doc(akunId)
        .update({'saldo': saldoBaru});
  }

  // ── TRANSACTIONS ──────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getTransactions({
    int? month,
    int? year,
    String? categoryId,
  }) async {
    if (uid == null) return [];
    Query query = _db.collection('users').doc(uid).collection('transactions');
    if (categoryId != null) query = query.where('category_id', isEqualTo: categoryId);

    final snap = await query.get();
    List<Map<String, dynamic>> result = snap.docs
        .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
        .toList();

    result.sort((a, b) {
      final dateA = b['date'] ?? '';
      final dateB = a['date'] ?? '';
      return dateA.compareTo(dateB);
    });

    if (month != null && year != null) {
      result = result.where((t) {
        final date = DateTime.tryParse(t['date'] ?? '');
        if (date == null) return false;
        return date.month == month && date.year == year;
      }).toList();
    }

    return result;
  }

  static Future<void> addTransaction(Map<String, dynamic> data) async {
    await _db
        .collection('users').doc(uid).collection('transactions')
        .add({...data, 'created_at': FieldValue.serverTimestamp()});
  }

  static Future<void> deleteTransaction(String txId) async {
    await _db
        .collection('users').doc(uid).collection('transactions')
        .doc(txId).delete();
  }

  // ── SUMMARY ───────────────────────────────────────────────────────────────

  static Future<Map<String, int>> getSummary(int month, int year) async {
    final allTxs = await getTransactions();

    final monthTxs = allTxs.where((t) {
      final date = DateTime.tryParse(t['date'] ?? '');
      if (date == null) return false;
      return date.month == month && date.year == year;
    }).toList();

    final income  = monthTxs.where((t) => t['type'] == 'income') .fold<int>(0, (s, t) => s + (t['amount'] as int));
    final expense = monthTxs.where((t) => t['type'] == 'expense').fold<int>(0, (s, t) => s + (t['amount'] as int));

    final allIncome  = allTxs.where((t) => t['type'] == 'income') .fold<int>(0, (s, t) => s + (t['amount'] as int));
    final allExpense = allTxs.where((t) => t['type'] == 'expense').fold<int>(0, (s, t) => s + (t['amount'] as int));

    return {
      'income': income,
      'expense': expense,
      'total_balance': allIncome - allExpense,
    };
  }

  // ── BUDGETS ───────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getBudgets(int month, int year) async {
    if (uid == null) return [];
    final snap = await _db
        .collection('users').doc(uid).collection('budgets')
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .get();
    return snap.docs
        .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
        .toList();
  }

  static Future<void> upsertBudget({
    required String categoryId,
    required int amount,
    required int month,
    required int year,
  }) async {
    if (uid == null) return;
    final snap = await _db
        .collection('users').doc(uid).collection('budgets')
        .where('category_id', isEqualTo: categoryId)
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .get();

    if (snap.docs.isEmpty) {
      await _db.collection('users').doc(uid).collection('budgets').add({
        'category_id': categoryId,
        'amount': amount,
        'month': month,
        'year': year,
      });
    } else {
      await snap.docs.first.reference.update({'amount': amount});
    }
  }
}