import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, Map<String, dynamic>> _userCache = {};
  final Map<String, StreamSubscription> _subscriptions = {};

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId];
    }

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final userData = doc.data()!;
        _userCache[userId] = userData;
        return userData;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<Map<String, dynamic>?> getUserStream(String userId) {
    if (_userCache.containsKey(userId)) {
      return Stream.value(_userCache[userId]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data();
          if (data != null) {
            _userCache[userId] = data;
          }
          return data;
        });
  }

  void cacheUser(String userId, Map<String, dynamic> userData) {
    _userCache[userId] = userData;
  }

  void clearCache() {
    _userCache.clear();
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  void dispose() {
    clearCache();
  }
}