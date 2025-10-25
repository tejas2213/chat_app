import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:chat_app/features/chat/domain/services/chat_service.dart';
part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService;

  ChatBloc({required ChatService chatService}) 
      : _chatService = chatService,
        super(ChatInitial()) {
    on<SendTextMessageEvent>(_onSendTextMessage);
    on<SendVoiceMessageEvent>(_onSendVoiceMessage);
    on<LoadMessagesEvent>(_onLoadMessages);
    on<StartRecordingEvent>(_onStartRecording);
    on<StopRecordingEvent>(_onStopRecording);
    on<PlayAudioEvent>(_onPlayAudio);
    on<StopAudioEvent>(_onStopAudio);
  }

  void _onSendTextMessage(SendTextMessageEvent event, Emitter<ChatState> emit) async {
    try {
      await _chatService.sendTextMessage(
        event.chatId,
        event.text,
        event.senderId,
        event.receiverId,
      );
      emit(MessageSent());
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onSendVoiceMessage(SendVoiceMessageEvent event, Emitter<ChatState> emit) async {
    try {
      await _chatService.sendVoiceMessage(
        event.chatId,
        event.filePath,
        event.senderId,
        event.receiverId,
      );
      emit(VoiceMessageSent(event.filePath));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onLoadMessages(LoadMessagesEvent event, Emitter<ChatState> emit) async {
    try {
      final messageStream = _chatService.getMessageStream(event.chatId);
      await emit.forEach(
        messageStream,
        onData: (messages) => MessagesLoaded(messages),
        onError: (error, _) => ChatError(error.toString()),
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onStartRecording(StartRecordingEvent event, Emitter<ChatState> emit) async {
    try {
      final path = await _chatService.startRecording();
      emit(RecordingStarted(path));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onStopRecording(StopRecordingEvent event, Emitter<ChatState> emit) async {
    try {
      final path = await _chatService.stopRecording();
      if (path != null) {
        emit(RecordingStopped(path));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onPlayAudio(PlayAudioEvent event, Emitter<ChatState> emit) async {
    try {
      await _chatService.playAudio(event.url);
      emit(AudioPlaying(event.url));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onStopAudio(StopAudioEvent event, Emitter<ChatState> emit) async {
    try {
      await _chatService.stopAudio();
      emit(AudioStopped());
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}