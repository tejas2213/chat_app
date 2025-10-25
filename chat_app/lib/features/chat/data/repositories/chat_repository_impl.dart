import 'package:chat_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<Map<String, dynamic>>> getMessages(String chatId) {
    return remoteDataSource.getMessages(chatId);
  }

  @override
  Future<void> sendTextMessage(String chatId, String text, String senderId, String receiverId) async {
    return await remoteDataSource.sendTextMessage(chatId, text, senderId, receiverId);
  }

  @override
  Future<String> sendVoiceMessage(String chatId, String filePath, String senderId, String receiverId) async {
    return await remoteDataSource.sendVoiceMessage(chatId, filePath, senderId, receiverId);
  }
}