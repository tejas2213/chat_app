import 'package:chat_app/features/friends/domain/repositories/friends_repository.dart';

class GetUsersUseCase {
  final FriendsRepository repository;

  GetUsersUseCase(this.repository);

  Stream<List<Map<String, dynamic>>> call() {
    return repository.getUsers();
  }
}