import 'package:dartz/dartz.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<String, void>> call(String chatId, String text, String senderId, String receiverId) async {
    try {
      final result = await repository.sendTextMessage(chatId, text, senderId, receiverId);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }
}