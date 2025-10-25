import 'package:dartz/dartz.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';

class SendVoiceMessageUseCase {
  final ChatRepository repository;

  SendVoiceMessageUseCase(this.repository);

  Future<Either<String, String>> call(String chatId, String filePath, String senderId, String receiverId) async {
    try {
      final result = await repository.sendVoiceMessage(chatId, filePath, senderId, receiverId);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }
}