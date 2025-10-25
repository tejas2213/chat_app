import 'package:dartz/dartz.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  Future<Either<String, String>> call(String phoneNumber) async {
    try {
      final result = await repository.sendOtp(phoneNumber);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }
}