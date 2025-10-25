import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';

class ChatController {
  static void handleChatState(BuildContext context, ChatState state) {
    if (state is ChatError) {
      _showErrorSnackBar(context, state.message);
    } else if (state is MessageSent) {
      _showSuccessSnackBar(context, 'Message sent successfully');
    } else if (state is VoiceMessageSent) {
      _showSuccessSnackBar(context, 'Voice message sent successfully');
    } else if (state is RecordingStarted) {
      _showInfoSnackBar(context, 'Recording started');
    } else if (state is RecordingStopped) {
      _showInfoSnackBar(context, 'Recording stopped');
    }
  }

  static void sendTextMessage(BuildContext context, String chatId, String text, String senderId, String receiverId) {
    context.read<ChatBloc>().add(SendTextMessageEvent(chatId, text, senderId, receiverId));
  }

  static void sendVoiceMessage(BuildContext context, String chatId, String filePath, String senderId, String receiverId) {
    context.read<ChatBloc>().add(SendVoiceMessageEvent(chatId, filePath, senderId, receiverId));
  }

  static void loadMessages(BuildContext context, String chatId) {
    context.read<ChatBloc>().add(LoadMessagesEvent(chatId));
  }

  static void startRecording(BuildContext context) {
    context.read<ChatBloc>().add(const StartRecordingEvent());
  }

  static void stopRecording(BuildContext context) {
    context.read<ChatBloc>().add(const StopRecordingEvent());
  }

  static void playAudio(BuildContext context, String url) {
    context.read<ChatBloc>().add(PlayAudioEvent(url));
  }

  static void stopAudio(BuildContext context) {
    context.read<ChatBloc>().add(const StopAudioEvent());
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  static void _showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
