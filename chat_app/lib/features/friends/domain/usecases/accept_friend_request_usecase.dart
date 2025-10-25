import 'package:dartz/dartz.dart';
import 'package:chat_app/features/friends/domain/repositories/friends_repository.dart';

class AcceptFriendRequestUseCase {
  final FriendsRepository repository;

  AcceptFriendRequestUseCase(this.repository);

  Future<Either<String, void>> call(String requestId) async {
    try {
      final result = await repository.acceptFriendRequest(requestId);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }
}