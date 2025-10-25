import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';

class CheckLoginStatusUseCase {
  final AuthRepository repository;

  CheckLoginStatusUseCase(this.repository);

  Future<bool> call() {
    return repository.isUserLoggedIn();
  }
}
