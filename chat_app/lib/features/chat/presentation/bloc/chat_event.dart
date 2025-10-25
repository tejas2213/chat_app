part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class LoadMessagesEvent extends ChatEvent {
  final String chatId;

  const LoadMessagesEvent(this.chatId);

  @override
  List<Object> get props => [chatId];
}

class SendTextMessageEvent extends ChatEvent {
  final String chatId;
  final String text;
  final String senderId;
  final String receiverId;

  const SendTextMessageEvent(
    this.chatId,
    this.text,
    this.senderId,
    this.receiverId,
  );

  @override
  List<Object> get props => [chatId, text, senderId, receiverId];
}

class SendVoiceMessageEvent extends ChatEvent {
  final String chatId;
  final String filePath;
  final String senderId;
  final String receiverId;

  const SendVoiceMessageEvent(
    this.chatId,
    this.filePath,
    this.senderId,
    this.receiverId,
  );

  @override
  List<Object> get props => [chatId, filePath, senderId, receiverId];
}

class StartRecordingEvent extends ChatEvent {
  const StartRecordingEvent();
}

class StopRecordingEvent extends ChatEvent {
  const StopRecordingEvent();
}

class PlayAudioEvent extends ChatEvent {
  final String url;

  const PlayAudioEvent(this.url);

  @override
  List<Object> get props => [url];
}

class StopAudioEvent extends ChatEvent {
  const StopAudioEvent();
}