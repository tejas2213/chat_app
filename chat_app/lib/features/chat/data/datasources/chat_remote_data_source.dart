import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

abstract class ChatRemoteDataSource {
  Stream<List<Map<String, dynamic>>> getMessages(String chatId);
  Future<void> sendTextMessage(String chatId, String text, String senderId, String receiverId);
  Future<String> sendVoiceMessage(String chatId, String filePath, String senderId, String receiverId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Stream<List<Map<String, dynamic>>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'text': data['text'] ?? '',
                'audioUrl': data['audioUrl'] ?? '',
                'senderId': data['senderId'] ?? '',
                'type': data['type'] ?? 'text',
                'timestamp': data['timestamp'] ?? Timestamp.now(),
              };
            }).toList());
  }

  @override
  Future<void> sendTextMessage(String chatId, String text, String senderId, String receiverId) async {
    await _firestore.collection('chats').doc(chatId).set({
      'participants': [senderId, receiverId],
      'lastMessage': text,
      'lastMessageTime': DateTime.now(),
      'updatedAt': DateTime.now(),
    }, SetOptions(merge: true));

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': senderId,
      'receiverId': receiverId,
      'type': 'text',
      'timestamp': DateTime.now(),
    });

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': DateTime.now(),
      'updatedAt': DateTime.now(),
    });
  }

  @override
  Future<String> sendVoiceMessage(String chatId, String filePath, String senderId, String receiverId) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        throw Exception('Audio file not found');
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('Audio file is empty');
      }

      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}_$senderId.aac';
      final ref = _storage.ref().child('voice_messages/$fileName');
      
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'audio/aac',
          customMetadata: {
            'senderId': senderId,
            'receiverId': receiverId,
            'chatId': chatId,
            'uploadTime': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _firestore.collection('chats').doc(chatId).set({
        'participants': [senderId, receiverId],
        'lastMessage': '🎤 Voice message',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'audioUrl': downloadUrl,
        'senderId': senderId,
        'receiverId': receiverId,
        'type': 'audio',
        'timestamp': FieldValue.serverTimestamp(),
        'duration': 0, 
        'fileSize': fileSize,
        'fileName': fileName,
      });

      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': '🎤 Voice message',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to send voice message: ${e.toString()}');
    }
  }
}