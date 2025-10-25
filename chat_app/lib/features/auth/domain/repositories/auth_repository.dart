import 'package:chat_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<String> sendOtp(String phoneNumber);
  Future<UserEntity> verifyOtp(String verificationId, String otp);
  Future<void> logout();
  Future<bool> isUserLoggedIn();
  Future<UserEntity?> getCurrentUser();
  Stream<UserEntity?> get authStateChanges;
}