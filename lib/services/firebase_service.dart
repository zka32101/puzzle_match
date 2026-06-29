import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInAnonymously() async {
    await _auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<AppUser?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!, doc.id);
  }

  Future<void> createUser(AppUser user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  Future<void> updateStreak(String userId, int streak) async {
    await _db.collection('users').doc(userId).update({
      'currentStreak': streak,
      'lastPlayedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> recordCloseCall({
    required String userId,
    required String puzzleId,
    required int level,
    required int wrongCellCount,
  }) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    await _db
        .collection('close_call_stats')
        .doc(userId)
        .collection(today)
        .add({
      'puzzleId': puzzleId,
      'level': level,
      'wrongCellCount': wrongCellCount,
      'recordedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> hasPlayedToday(String userId, String puzzleId) async {
    final query = await _db
        .collection('solutions')
        .where('userId', isEqualTo: userId)
        .where('puzzleId', isEqualTo: puzzleId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }
}
