import 'package:dartz/dartz.dart';
import 'package:chat_app/features/friends/domain/repositories/friends_repository.dart';

class RejectFriendRequestUseCase {
  final FriendsRepository repository;

  RejectFriendRequestUseCase(this.repository);

  Future<Either<String, void>> call(String requestId) async {
    try {
      await repository.rejectFriendRequest(requestId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
