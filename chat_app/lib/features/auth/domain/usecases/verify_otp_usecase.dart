import 'package:dartz/dartz.dart';
import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<Either<String, UserEntity>> call(String verificationId, String otp) async {
    try {
      final result = await repository.verifyOtp(verificationId, otp);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }
}