import 'package:dartz/dartz.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<String, void>> call() async {
    try {
      await repository.logout();
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
