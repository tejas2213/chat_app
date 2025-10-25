abstract class ChatRepository {
  Stream<List<Map<String, dynamic>>> getMessages(String chatId);
  Future<void> sendTextMessage(String chatId, String text, String senderId, String receiverId);
  Future<String> sendVoiceMessage(String chatId, String filePath, String senderId, String receiverId);
}