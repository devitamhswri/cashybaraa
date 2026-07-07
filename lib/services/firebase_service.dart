import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  static final _auth = FirebaseAuth.instance;
  static final _db   = FirebaseFirestore.instance;

  // ── AUTH ──────────────────────────────────────────────────────────────────

  static Future<String?> register(String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final uid  = cred.user!.uid;
      await _db.collection('users').doc(uid).set({
        'name': name, 'email': email,
        'provider': 'password',
        'created_at': FieldValue.serverTimestamp(),
      });
      await _createDefaultCategories(uid);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return 'Email sudah terdaftar';
      if (e.code == 'weak-password')        return 'Password minimal 8 karakter';
      return 'Registrasi gagal';
    }
  }

  static Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _ensureProviderField();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'Email tidak ditemukan';
      if (e.code == 'wrong-password') return 'Password salah';
      return 'Login gagal';
    }
  }

  static Future<String?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return 'Login dibatalkan';
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      final uid  = cred.user!.uid;
      final doc  = await _db.collection('users').doc(uid).get();
      if (!doc.exists) {
        await _db.collection('users').doc(uid).set({
          'name':       cred.user!.displayName ?? '',
          'email':      cred.user!.email ?? '',
          'provider':   'google.com',
          'created_at': FieldValue.serverTimestamp(),
        });
        await _createDefaultCategories(uid);
      } else {
        await _ensureProviderField();
      }
      return null;
    } catch (_) {
      return 'Login Google gagal';
    }
  }

  static Future<void> _ensureProviderField() async {
    if (uid == null) return;
    final doc  = await _db.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null || data['provider'] != null) return;
    final providers = _auth.currentUser?.providerData.map((p) => p.providerId).toList() ?? [];
    final provider  = providers.contains('google.com') ? 'google.com' : 'password';
    await _db.collection('users').doc(uid).update({'provider': provider});
  }

  static Future<void> logout() async => await _auth.signOut();

  static Future<void> signOutGoogle() async {
    try { await GoogleSignIn().signOut(); } catch (_) {}
  }

  static Future<String?> sendPasswordReset(String email) async {
    try {
      final snap = await _db.collection('users').where('email', isEqualTo: email).limit(1).get();
      if (snap.docs.isEmpty) return 'Email tidak terdaftar.';
      final userData = snap.docs.first.data();
      if (userData['provider'] == 'google.com') {
        return 'Akun ini terdaftar menggunakan Google. Silakan masuk dengan tombol "Masuk dengan Google".';
      }
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') return 'Format email tidak valid.';
      return 'Gagal mengirim email reset. Coba lagi.';
    } catch (_) {
      return 'Terjadi kesalahan. Coba lagi.';
    }
  }

  static User?   get currentUser => _auth.currentUser;
  static String? get uid         => _auth.currentUser?.uid;
  static bool    get isLoggedIn  => _auth.currentUser != null;

  // ── USER ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getUser() async {
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  static Future<String?> updateUser({required String nama, required String email}) async {
    try {
      if (uid == null) return 'Tidak ada user';
      await _db.collection('users').doc(uid).update({'name': nama, 'email': email});
      if (currentUser?.email != email) {
        await currentUser?.verifyBeforeUpdateEmail(email);
      }
      return null;
    } catch (_) {
      return 'Gagal update profil';
    }
  }

  static Future<String?> updatePassword({
    required String passwordLama,
    required String passwordBaru,
  }) async {
    try {
      final user = currentUser;
      if (user == null) return 'Tidak ada user';
      final cred = EmailAuthProvider.credential(email: user.email!, password: passwordLama);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(passwordBaru);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') return 'Password lama salah';
      return 'Gagal mengubah password';
    }
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
    return snap.docs.map((d) => {'id': d.id, ...(d.data() as Map<String, dynamic>)}).toList();
  }

  static Future<String> addCategory(Map<String, dynamic> data) async {
    final ref = await _db.collection('users').doc(uid).collection('categories')
        .add({...data, 'created_at': FieldValue.serverTimestamp()});
    return ref.id;
  }

  static Future<void> deleteCategory(String categoryId) async {
    await _db.collection('users').doc(uid).collection('categories').doc(categoryId).delete();
  }

  // ── ACCOUNTS ──────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getAkun() async {
    if (uid == null) return [];
    final snap = await _db.collection('users').doc(uid).collection('accounts')
        .orderBy('created_at').get();
    return snap.docs.map((d) => {'id': d.id, ...(d.data() as Map<String, dynamic>)}).toList();
  }

  static Future<String> addAkun(Map<String, dynamic> data) async {
    final ref = await _db.collection('users').doc(uid).collection('accounts')
        .add({...data, 'created_at': FieldValue.serverTimestamp()});
    return ref.id;
  }

  static Future<void> updateSaldoAkun(String akunId, int saldoBaru) async {
    await _db.collection('users').doc(uid).collection('accounts')
        .doc(akunId).update({'saldo': saldoBaru});
  }

  // ── TRANSACTIONS ──────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getTransactions({
    int? month, int? year, String? categoryId,
  }) async {
    if (uid == null) return [];
    Query query = _db.collection('users').doc(uid).collection('transactions');
    if (categoryId != null) query = query.where('category_id', isEqualTo: categoryId);

    final snap = await query.get();
    List<Map<String, dynamic>> result = snap.docs
        .map((d) => {'id': d.id, ...(d.data() as Map<String, dynamic>)})
        .toList();

    result.sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));

    if (month != null && year != null) {
      result = result.where((t) {
        final date = DateTime.tryParse(t['date'] ?? '');
        return date != null && date.month == month && date.year == year;
      }).toList();
    }
    return result;
  }

  static Future<void> addTransaction(Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).collection('transactions')
        .add({...data, 'created_at': FieldValue.serverTimestamp()});
  }

  static Future<void> deleteTransaction(String txId) async {
    await _db.collection('users').doc(uid).collection('transactions').doc(txId).delete();
  }

  // ── SUMMARY ───────────────────────────────────────────────────────────────

  static Future<Map<String, int>> getSummary(int month, int year) async {
    final allTxs = await getTransactions();
    final monthTxs = allTxs.where((t) {
      final date = DateTime.tryParse(t['date'] ?? '');
      return date != null && date.month == month && date.year == year;
    }).toList();

    final income  = monthTxs.where((t) => t['type'] == 'income') .fold<int>(0, (s, t) => s + (t['amount'] as int));
    final expense = monthTxs.where((t) => t['type'] == 'expense').fold<int>(0, (s, t) => s + (t['amount'] as int));
    final allIncome  = allTxs.where((t) => t['type'] == 'income') .fold<int>(0, (s, t) => s + (t['amount'] as int));
    final allExpense = allTxs.where((t) => t['type'] == 'expense').fold<int>(0, (s, t) => s + (t['amount'] as int));

    return {
      'income': income, 'expense': expense,
      'total_balance': allIncome - allExpense,
    };
  }

  // ── RESET & HAPUS AKUN ────────────────────────────────────────────────────

  static Future<void> resetSemuaData() async {
    if (uid == null) return;
    final txSnap = await _db.collection('users').doc(uid).collection('transactions').get();
    final batch1 = _db.batch();
    for (final doc in txSnap.docs) { batch1.delete(doc.reference); }
    await batch1.commit();

    final akunSnap = await _db.collection('users').doc(uid).collection('accounts').get();
    final batch2 = _db.batch();
    for (final doc in akunSnap.docs) { batch2.update(doc.reference, {'saldo': 0}); }
    await batch2.commit();
  }

  // Hapus akun dengan verifikasi password (untuk flow yang butuh re-auth)
  static Future<String?> hapusAkunPermanen({required String password}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'Tidak ada user yang login';
      final cred = EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(cred);
      await _hapusSemuaKoleksi();
      await _db.collection('users').doc(uid).delete();
      await user.delete();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') return 'Password salah';
      return 'Gagal menghapus akun: ${e.message}';
    }
  }

  // Hapus akun langsung tanpa password (token masih fresh dari login baru)
  static Future<String?> deleteAccountDirect() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'Tidak ada user yang login';
      await _hapusSemuaKoleksi();
      await _db.collection('users').doc(uid).delete();
      await user.delete();
      return null;
    } on FirebaseAuthException catch (e) {
      // Kalau token expired, Firebase minta re-auth
      if (e.code == 'requires-recent-login') {
        return 'Sesi kamu sudah lama. Silakan logout lalu login ulang, kemudian coba hapus akun lagi.';
      }
      return 'Gagal menghapus akun: ${e.message}';
    } catch (e) {
      return 'Gagal menghapus akun: $e';
    }
  }

  static Future<void> _hapusSemuaKoleksi() async {
    if (uid == null) return;
    for (final col in ['transactions', 'accounts', 'categories', 'budgets']) {
      final snap  = await _db.collection('users').doc(uid).collection(col).get();
      final batch = _db.batch();
      for (final doc in snap.docs) { batch.delete(doc.reference); }
      await batch.commit();
    }
  }

  // ── BUDGETS ───────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getBudgets(int month, int year) async {
    if (uid == null) return [];
    final snap = await _db.collection('users').doc(uid).collection('budgets')
        .where('month', isEqualTo: month).where('year', isEqualTo: year).get();
    return snap.docs.map((d) => {'id': d.id, ...(d.data() as Map<String, dynamic>)}).toList();
  }

  static Future<void> upsertBudget({
    required String categoryId, required int amount,
    required int month,         required int year,
  }) async {
    if (uid == null) return;
    final snap = await _db.collection('users').doc(uid).collection('budgets')
        .where('category_id', isEqualTo: categoryId)
        .where('month', isEqualTo: month).where('year', isEqualTo: year).get();
    if (snap.docs.isEmpty) {
      await _db.collection('users').doc(uid).collection('budgets')
          .add({'category_id': categoryId, 'amount': amount, 'month': month, 'year': year});
    } else {
      await snap.docs.first.reference.update({'amount': amount});
    }
  }
}