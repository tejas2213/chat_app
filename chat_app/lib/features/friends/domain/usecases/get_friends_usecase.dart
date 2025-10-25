import 'package:chat_app/features/friends/domain/repositories/friends_repository.dart';

class GetFriendsUseCase {
  final FriendsRepository repository;

  GetFriendsUseCase(this.repository);

  Stream<List<Map<String, dynamic>>> call() {
    return repository.getFriends();
  }
}