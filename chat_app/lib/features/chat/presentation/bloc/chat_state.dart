part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class MessagesLoaded extends ChatState {
  final List<Map<String, dynamic>> messages;

  const MessagesLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}

class MessageSent extends ChatState {}

class VoiceMessageSent extends ChatState {
  final String filePath;

  const VoiceMessageSent(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class RecordingStarted extends ChatState {
  final String filePath;

  const RecordingStarted(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class RecordingStopped extends ChatState {
  final String filePath;

  const RecordingStopped(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class AudioPlaying extends ChatState {
  final String url;

  const AudioPlaying(this.url);

  @override
  List<Object> get props => [url];
}

class AudioStopped extends ChatState {}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}