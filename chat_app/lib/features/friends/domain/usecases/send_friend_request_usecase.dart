import 'package:dartz/dartz.dart';
import 'package:chat_app/features/friends/domain/repositories/friends_repository.dart';

class SendFriendRequestUseCase {
  final FriendsRepository repository;

  SendFriendRequestUseCase(this.repository);

  Future<Either<String, void>> call(String toUserId) async {
    try {
      final result = await repository.sendFriendRequest(toUserId);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }
}