import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:record/record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:just_audio/just_audio.dart';
import '../bloc/chat_bloc.dart';
import '../controllers/chat_controller.dart';
import '../widgets/audio_message_widget.dart';

class ChatView extends StatefulWidget {
  final String friendId;
  final String friendName;

  const ChatView({
    super.key,
    required this.friendId,
    this.friendName = 'Friend',
  });

  @override
  State<ChatView> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatView> {
  final _messageController = TextEditingController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  String? _currentUserId;
  int _recordingDuration = 0;
  Timer? _recordingTimer;
  String? _currentlyPlayingUrl;
  AudioPlayerState _audioPlayerState = AudioPlayerState.stopped;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

  String _getChatId() {
    if (_currentUserId == null) return '';
    final users = [_currentUserId!, widget.friendId]..sort();
    return 'chat_${users[0]}_${users[1]}';
  }

  Stream<List<Map<String, dynamic>>> _getMessageStream() {
    final chatId = _getChatId();
    if (chatId.isEmpty) return Stream.value([]);

    return FirebaseFirestore.instance
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

  Future<void> _sendTextMessage() async {
    if (_messageController.text.isEmpty || _currentUserId == null) return;

    final chatId = _getChatId();
    if (chatId.isEmpty) return;

    context.read<ChatBloc>().add(
          SendTextMessageEvent(
            chatId,
            _messageController.text,
            _currentUserId!,
            widget.friendId,
          ),
        );
    _messageController.clear();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<String> _getRecordingPath() async {
    final directory = await getTemporaryDirectory();
    final fileName = 'voice_message_${DateTime.now().millisecondsSinceEpoch}.aac';
    return path.join(directory.path, fileName);
  }

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission denied'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final recordingPath = await _getRecordingPath();
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );

      await _audioRecorder.start(config, path: recordingPath);
      if (mounted) {
        setState(() {
          _isRecording = true;
          _recordingDuration = 0;
        });
        
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              _recordingDuration++;
            });
          }
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recording started...'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      _recordingTimer?.cancel();
      _recordingTimer = null;
      
      final recordingPath = await _audioRecorder.stop();
      
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }

      if (recordingPath != null && _currentUserId != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recording stopped. Sending...'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 1),
            ),
          );
        }

        final chatId = _getChatId();
        if (chatId.isNotEmpty) {
          context.read<ChatBloc>().add(
                SendVoiceMessageEvent(
                  chatId, 
                  recordingPath, 
                  _currentUserId!, 
                  widget.friendId
                ),
              );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to send voice message'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recording failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['senderId'] == _currentUserId;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message['type'] == 'text')
                  Text(
                    message['text'],
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                    ),
                  ),
                if (message['type'] == 'audio')
                  AudioMessageWidget(
                    audioUrl: message['audioUrl'],
                    duration: message['duration'] ?? 0,
                    isMe: isMe,
                    playerState: _audioPlayerState,
                    currentlyPlayingUrl: _currentlyPlayingUrl ?? '',
                    onTap: () => _playAudioMessage(message['audioUrl']),
                  ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(message['timestamp']),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _playAudioMessage(String audioUrl) async {
    if (_audioPlayerState == AudioPlayerState.loading) {
      return;
    }

    try {
      if (_currentlyPlayingUrl == audioUrl && _audioPlayerState == AudioPlayerState.playing) {
        await _pauseAudio();
        return;
      }

      if (_currentlyPlayingUrl == audioUrl && _audioPlayerState == AudioPlayerState.paused) {
        await _resumeAudio();
        return;
      }

      if (_audioPlayerState != AudioPlayerState.stopped) {
        await _stopAudio();
      }

      setState(() {
        _audioPlayerState = AudioPlayerState.loading;
        _currentlyPlayingUrl = audioUrl;
      });

      await _audioPlayer.setUrl(audioUrl);
      _setupAudioPlayerListener();

      setState(() {
        _audioPlayerState = AudioPlayerState.playing;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Playing'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 1),
          ),
        );
      }

      await _audioPlayer.play();

    } catch (e) {
      if (mounted) {
        setState(() {
          _audioPlayerState = AudioPlayerState.error;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _setupAudioPlayerListener() {
    _playerStateSubscription?.cancel();
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;

      switch (state.processingState) {
        case ProcessingState.completed:
          setState(() {
            _audioPlayerState = AudioPlayerState.stopped;
            _currentlyPlayingUrl = null;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Stopped'),
                backgroundColor: Colors.grey,
                duration: Duration(seconds: 1),
              ),
            );
          }
          break;
        case ProcessingState.loading:
          if (_audioPlayerState != AudioPlayerState.loading) {
            setState(() {
              _audioPlayerState = AudioPlayerState.loading;
            });
          }
          break;
        case ProcessingState.ready:
          if (state.playing) {
            setState(() {
              _audioPlayerState = AudioPlayerState.playing;
            });
          } else {
            setState(() {
              _audioPlayerState = AudioPlayerState.paused;
            });
          }
          break;
        case ProcessingState.idle:
          setState(() {
            _audioPlayerState = AudioPlayerState.stopped;
            _currentlyPlayingUrl = null;
          });
          break;
        case ProcessingState.buffering:
          setState(() {
            _audioPlayerState = AudioPlayerState.loading;
          });
          break;
      }
    });
  }

  Future<void> _pauseAudio() async {
    try {
      await _audioPlayer.pause();
      setState(() {
        _audioPlayerState = AudioPlayerState.paused;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paused'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pause audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resumeAudio() async {
    try {
      await _audioPlayer.play();
      setState(() {
        _audioPlayerState = AudioPlayerState.playing;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Playing'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resume audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopAudio() async {
    try {
      await _audioPlayer.stop();
      setState(() {
        _audioPlayerState = AudioPlayerState.stopped;
        _currentlyPlayingUrl = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stopped'),
            backgroundColor: Colors.grey,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final time = timestamp.toDate();
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '';
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _playerStateSubscription?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat with ${widget.friendName}'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getMessageStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
      
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
      
                  final messages = snapshot.data ?? [];
      
                  if (messages.isEmpty) {
                    return const Center(
                      child: Text('No messages yet. Start a conversation!'),
                    );
                  }
      
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      return _buildMessageBubble(message);
                    },
                  );
                },
              ),
            ),
            BlocListener<ChatBloc, ChatState>(
              listener: (context, state) => ChatController.handleChatState(context, state),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendTextMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _isRecording ? 120 : 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.red : Colors.blue,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: _isRecording ? [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ] : null,
                      ),
                      child: _isRecording 
                          ? InkWell(
                              onTap: _toggleRecording,
                              borderRadius: BorderRadius.circular(24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.stop, color: Colors.white, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Stop (${_formatDuration(_recordingDuration * 1000)})',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.mic, color: Colors.white),
                              onPressed: _toggleRecording,
                            ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendTextMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}