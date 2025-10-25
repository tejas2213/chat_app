import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:just_audio/just_audio.dart';

abstract class ChatService {
  Future<String> getCurrentUserId();
  String generateChatId(String userId1, String userId2);
  Stream<List<Map<String, dynamic>>> getMessageStream(String chatId);
  Future<void> sendTextMessage(String chatId, String text, String senderId, String receiverId);
  Future<void> sendVoiceMessage(String chatId, String filePath, String senderId, String receiverId);
  Future<String> startRecording();
  Future<String?> stopRecording();
  Future<void> playAudio(String url);
  Future<void> stopAudio();
  Stream<AudioPlayerState> get audioPlayerStateStream;
  bool get isRecording;
  int get recordingDuration;
}

class ChatServiceImpl implements ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isRecording = false;
  int _recordingDuration = 0;
  Timer? _recordingTimer;
  String? _currentRecordingPath;

  @override
  Future<String> getCurrentUserId() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  @override
  String generateChatId(String userId1, String userId2) {
    final users = [userId1, userId2]..sort();
    return 'chat_${users[0]}_${users[1]}';
  }

  @override
  Stream<List<Map<String, dynamic>>> getMessageStream(String chatId) {
    if (chatId.isEmpty) return Stream.value([]);

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
                'duration': data['duration'] ?? 0,
              };
            }).toList());
  }

  @override
  Future<void> sendTextMessage(String chatId, String text, String senderId, String receiverId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': senderId,
      'receiverId': receiverId,
      'type': 'text',
      'timestamp': Timestamp.now(),
    });
  }

  @override
  Future<void> sendVoiceMessage(String chatId, String filePath, String senderId, String receiverId) async {
    final storageRef = FirebaseStorage.instance.ref().child('audio_messages/${DateTime.now().millisecondsSinceEpoch}.m4a');
    final uploadTask = storageRef.putFile(File(filePath));
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    final audioPlayer = AudioPlayer();
    await audioPlayer.setFilePath(filePath);
    final duration = audioPlayer.duration ?? Duration.zero;

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'audioUrl': downloadUrl,
      'senderId': senderId,
      'receiverId': receiverId,
      'type': 'audio',
      'timestamp': Timestamp.now(),
      'duration': duration.inSeconds,
    });

    await audioPlayer.dispose();
  }

  @override
  Future<String> startRecording() async {
    if (_isRecording) throw Exception('Already recording');

    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _currentRecordingPath = path.join(directory.path, fileName);

    await _audioRecorder.start(const RecordConfig(), path: _currentRecordingPath!);
    _isRecording = true;
    _recordingDuration = 0;

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingDuration++;
    });

    return _currentRecordingPath!;
  }

  @override
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    await _audioRecorder.stop();
    _isRecording = false;
    _recordingTimer?.cancel();
    _recordingTimer = null;

    final path = _currentRecordingPath;
    _currentRecordingPath = null;
    return path;
  }

  @override
  Future<void> playAudio(String url) async {
    await _audioPlayer.setUrl(url);
    await _audioPlayer.play();
  }

  @override
  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }

  @override
  Stream<AudioPlayerState> get audioPlayerStateStream => _audioPlayer.playerStateStream.map((state) => state.playing ? AudioPlayerState.playing : AudioPlayerState.stopped);

  @override
  bool get isRecording => _isRecording;

  @override
  int get recordingDuration => _recordingDuration;

  void dispose() {
    _recordingTimer?.cancel();
    _audioPlayer.dispose();
  }
}

enum AudioPlayerState { playing, stopped }
