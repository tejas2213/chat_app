import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';

abstract class AuthService {
  Future<String> sendOtp(String phoneNumber);
  Future<UserEntity> verifyOtp(String verificationId, String otp);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<bool> isLoggedIn();
  Stream<UserEntity?> get authStateChanges;
}

class AuthServiceImpl implements AuthService {
  final AuthRepository _repository;
  String? _verificationId;

  AuthServiceImpl(this._repository);

  @override
  Future<String> sendOtp(String phoneNumber) async {
    _verificationId = await _repository.sendOtp(phoneNumber);
    return _verificationId!;
  }

  @override
  Future<UserEntity> verifyOtp(String verificationId, String otp) async {
    final verificationIdToUse = _verificationId ?? verificationId;
    
    if (verificationIdToUse.isEmpty) {
      throw Exception('No verification ID found. Please request OTP again.');
    }

    return await _repository.verifyOtp(verificationIdToUse, otp);
  }

  @override
  Future<void> logout() async {
    await _repository.logout();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await _repository.getCurrentUser();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _repository.isUserLoggedIn();
  }

  @override
  Stream<UserEntity?> get authStateChanges => _repository.authStateChanges;
}
