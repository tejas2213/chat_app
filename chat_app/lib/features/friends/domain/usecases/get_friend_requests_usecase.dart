import 'package:chat_app/features/friends/domain/repositories/friends_repository.dart';

class GetFriendRequestsUseCase {
  final FriendsRepository repository;

  GetFriendRequestsUseCase(this.repository);

  Stream<List<Map<String, dynamic>>> call() {
    return repository.getFriendRequests();
  }
}