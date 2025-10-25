import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class FriendsRemoteDataSource {
  Stream<List<Map<String, dynamic>>> getUsers();
  Stream<List<Map<String, dynamic>>> getFriendRequests();
  Stream<List<Map<String, dynamic>>> getFriends();
  Future<void> sendFriendRequest(String toUserId);
  Future<void> acceptFriendRequest(String requestId);
  Future<void> rejectFriendRequest(String requestId);
  Future<void> cancelFriendRequest(String requestId);
  Future<List<Map<String, dynamic>>> searchUsers(String query);
}

class FriendsRemoteDataSourceImpl implements FriendsRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  @override
  Stream<List<Map<String, dynamic>>> getUsers() {
    if (_currentUserId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .where('uid', isNotEqualTo: _currentUserId)
        .snapshots()
        .asyncMap(
          (snapshot) async {
            try {
              final users = <Map<String, dynamic>>[];
              final userIds = <String>[];
              
              for (final doc in snapshot.docs) {
                final data = doc.data();
                
                if (data['uid'] == null || data['uid'] == _currentUserId) {
                  continue;
                }

                final user = {
                  'id': doc.id,
                  'uid': data['uid'] as String,
                  'phoneNumber': data['phoneNumber'] as String? ?? '',
                  'name': data['name'] as String? ?? data['phoneNumber'] as String? ?? 'Unknown User',
                  'createdAt': data['createdAt'],
                };
                
                users.add(user);
                userIds.add(data['uid'] as String);
              }

              if (userIds.isEmpty) {
                return users;
              }

              final batch = await Future.wait([
                _getPendingRequestsBatch(userIds),
                _getFriendshipsBatch(userIds),
              ]);

              final pendingRequests = batch[0];
              final friendships = batch[1];

              for (int i = 0; i < users.length; i++) {
                final uid = userIds[i];
                users[i]['hasPendingRequest'] = pendingRequests[uid] ?? false;
                users[i]['isFriend'] = friendships[uid] ?? false;
              }

              final uniqueUsers = <String, Map<String, dynamic>>{};
              for (final user in users) {
                final uid = user['uid'] as String;
                if (!uniqueUsers.containsKey(uid)) {
                  uniqueUsers[uid] = user;
                }
              }

              return uniqueUsers.values.toList();
            } catch (e) {
              return <Map<String, dynamic>>[];
            }
          },
        )
        .handleError((error) {
          return <Map<String, dynamic>>[];
        });
  }

  Future<Map<String, bool>> _getPendingRequestsBatch(List<String> userIds) async {
    try {
      final requests = await _firestore
          .collection('friend_requests')
          .where('fromUserId', isEqualTo: _currentUserId)
          .where('toUserId', whereIn: userIds)
          .where('status', isEqualTo: 'pending')
          .get();

      final result = <String, bool>{};
      for (final doc in requests.docs) {
        final data = doc.data();
        result[data['toUserId'] as String] = true;
      }
      return result;
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, bool>> _getFriendshipsBatch(List<String> userIds) async {
    try {
      final friendships = await _firestore
          .collection('friends')
          .where('users', arrayContains: _currentUserId)
          .get();

      final result = <String, bool>{};
      for (final doc in friendships.docs) {
        final users = List<String>.from(doc.data()['users'] ?? []);
        for (final userId in users) {
          if (userId != _currentUserId && userIds.contains(userId)) {
            result[userId] = true;
          }
        }
      }
      return result;
    } catch (e) {
      return {};
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> getFriendRequests() {
    if (_currentUserId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('friend_requests')
        .where('toUserId', isEqualTo: _currentUserId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) {
            try {
              final requests = snapshot.docs.map((doc) {
                final data = doc.data();
                return {
                  'id': doc.id,
                  'fromUserId': data['fromUserId'] as String,
                  'toUserId': data['toUserId'] as String,
                  'status': data['status'] as String,
                  'createdAt': data['createdAt'],
                  'updatedAt': data['updatedAt'],
                };
              }).toList();
              return requests;
            } catch (e) {
              return <Map<String, dynamic>>[];
            }
          },
        )
        .handleError((error) {
          return <Map<String, dynamic>>[];
        });
  }

  @override
  Stream<List<Map<String, dynamic>>> getFriends() {
    if (_currentUserId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('friends')
        .where('users', arrayContains: _currentUserId)
        .snapshots()
        .map(
          (snapshot) {
            try {
              final friendsMap = <String, Map<String, dynamic>>{};
              
              for (final doc in snapshot.docs) {
                final data = doc.data();
                final users = List<String>.from(data['users'] ?? []);
                
                if (users.length != 2) continue;
                
                final friendId = users.firstWhere((id) => id != _currentUserId);
                
                if (friendsMap.containsKey(friendId)) {
                  final existingFriend = friendsMap[friendId]!;
                  final existingCreatedAt = existingFriend['createdAt'];
                  final currentCreatedAt = data['createdAt'];
                  
                  if (currentCreatedAt != null && 
                      (existingCreatedAt == null || 
                       (currentCreatedAt as Timestamp).compareTo(existingCreatedAt as Timestamp) > 0)) {
                    friendsMap[friendId] = {
                      'id': doc.id,
                      'friendId': friendId,
                      'createdAt': data['createdAt'],
                      'acceptedFromRequest': data['acceptedFromRequest'],
                    };
                  }
                } else {
                  friendsMap[friendId] = {
                    'id': doc.id,
                    'friendId': friendId,
                    'createdAt': data['createdAt'],
                    'acceptedFromRequest': data['acceptedFromRequest'],
                  };
                }
              }
              
              return friendsMap.values.toList();
            } catch (e) {
              return <Map<String, dynamic>>[];
            }
          },
        )
        .handleError((error) {
          return <Map<String, dynamic>>[];
        });
  }

  @override
  Future<void> sendFriendRequest(String toUserId) async {
    try {
      if (_currentUserId.isEmpty) {
        throw Exception('User not authenticated');
      }
      if (toUserId.isEmpty) {
        throw Exception('Invalid user ID');
      }
      if (_currentUserId == toUserId) {
        throw Exception('Cannot send friend request to yourself');
      }

      final friendship = await _firestore
          .collection('friends')
          .where('users', arrayContains: _currentUserId)
          .get();

      final isAlreadyFriend = friendship.docs.any((doc) {
        final users = List<String>.from(doc.data()['users'] ?? []);
        return users.contains(toUserId);
      });

      if (isAlreadyFriend) {
        throw Exception('Users are already friends');
      }

      final existingRequest = await _firestore
          .collection('friend_requests')
          .where('fromUserId', isEqualTo: _currentUserId)
          .where('toUserId', isEqualTo: toUserId)
          .where('status', whereIn: ['pending', 'accepted'])
          .get();

      if (existingRequest.docs.isNotEmpty) {
        throw Exception('Friend request already sent or accepted');
      }

      final reverseRequest = await _firestore
          .collection('friend_requests')
          .where('fromUserId', isEqualTo: toUserId)
          .where('toUserId', isEqualTo: _currentUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (reverseRequest.docs.isNotEmpty) {
        throw Exception('This user has already sent you a friend request');
      }

      await _firestore.collection('friend_requests').add({
        'fromUserId': _currentUserId,
        'toUserId': toUserId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to send friend request: ${e.toString()}');
    }
  }

  @override
  Future<void> acceptFriendRequest(String requestId) async {
    try {
      if (_currentUserId.isEmpty) {
        throw Exception('User not authenticated');
      }
      if (requestId.isEmpty) {
        throw Exception('Invalid request ID');
      }

      final requestDoc = await _firestore
          .collection('friend_requests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        throw Exception('Friend request not found');
      }

      final requestData = requestDoc.data()!;
      final fromUserId = requestData['fromUserId'] as String;
      final toUserId = requestData['toUserId'] as String;
      final status = requestData['status'] as String;

      if (toUserId != _currentUserId) {
        throw Exception('You can only accept requests sent to you');
      }

      if (status != 'pending') {
        throw Exception('Friend request is no longer pending');
      }

      final batch = _firestore.batch();

      batch.update(requestDoc.reference, {
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final users = [fromUserId, toUserId]..sort();
      final friendsRef = _firestore.collection('friends').doc();
      batch.set(friendsRef, {
        'users': users,
        'createdAt': FieldValue.serverTimestamp(),
        'acceptedFromRequest': requestId,
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to accept friend request: ${e.toString()}');
    }
  }

  @override
  Future<void> rejectFriendRequest(String requestId) async {
    try {
      if (_currentUserId.isEmpty) {
        throw Exception('User not authenticated');
      }
      if (requestId.isEmpty) {
        throw Exception('Invalid request ID');
      }

      final requestDoc = await _firestore
          .collection('friend_requests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        throw Exception('Friend request not found');
      }

      final requestData = requestDoc.data()!;
      final toUserId = requestData['toUserId'] as String;
      final status = requestData['status'] as String;

      if (toUserId != _currentUserId) {
        throw Exception('You can only reject requests sent to you');
      }

      if (status != 'pending') {
        throw Exception('Friend request is no longer pending');
      }

      await _firestore.collection('friend_requests').doc(requestId).update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to reject friend request: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelFriendRequest(String requestId) async {
    try {
      if (_currentUserId.isEmpty) {
        throw Exception('User not authenticated');
      }
      if (requestId.isEmpty) {
        throw Exception('Invalid request ID');
      }

      final requestDoc = await _firestore
          .collection('friend_requests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        throw Exception('Friend request not found');
      }

      final requestData = requestDoc.data()!;
      final fromUserId = requestData['fromUserId'] as String;
      final status = requestData['status'] as String;

      if (fromUserId != _currentUserId) {
        throw Exception('You can only cancel requests you sent');
      }

      if (status != 'pending') {
        throw Exception('Friend request is no longer pending');
      }

      await _firestore.collection('friend_requests').doc(requestId).delete();
    } catch (e) {
      throw Exception('Failed to cancel friend request: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('phoneNumber', isGreaterThanOrEqualTo: query)
          .where('phoneNumber', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return result.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'uid': data['uid'],
          'phoneNumber': data['phoneNumber'],
          'name': data['name'] ?? data['phoneNumber'],
          'createdAt': data['createdAt'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }
}
