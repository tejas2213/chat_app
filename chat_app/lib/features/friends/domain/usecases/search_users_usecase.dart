import 'package:dartz/dartz.dart';
import 'package:chat_app/features/friends/domain/repositories/friends_repository.dart';

class SearchUsersUseCase {
  final FriendsRepository repository;

  SearchUsersUseCase(this.repository);

  Future<Either<String, List<Map<String, dynamic>>>> call(String query) async {
    try {
      final result = await repository.searchUsers(query);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }
}