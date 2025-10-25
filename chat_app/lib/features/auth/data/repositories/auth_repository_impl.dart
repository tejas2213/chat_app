import 'package:chat_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:chat_app/features/auth/data/services/session_service.dart';
import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> sendOtp(String phoneNumber) async {
    return await remoteDataSource.sendOtp(phoneNumber);
  }

  @override
  Future<UserEntity> verifyOtp(String verificationId, String otp) async {
    final user = await remoteDataSource.verifyOtp(verificationId, otp);
    
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'phoneNumber': user.phoneNumber!,
          'name': user.displayName ?? user.phoneNumber,
          'createdAt': DateTime.now().toIso8601String(),
        });
      } else {
        await _firestore.collection('users').doc(user.uid).update({
          'lastLoginAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error saving user to Firestore: $e');
    }
    
    await SessionService.saveUserSession(user);
    
    return UserEntity(
      id: user.uid,
      phoneNumber: user.phoneNumber!,
      name: user.displayName,
    );
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    await SessionService.clearSession();
  }

  @override
  Future<bool> isUserLoggedIn() async {
    return _auth.currentUser != null;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    return UserEntity(
      id: user.uid,
      phoneNumber: user.phoneNumber ?? '',
      name: user.displayName,
    );
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserEntity(
        id: user.uid,
        phoneNumber: user.phoneNumber ?? '',
        name: user.displayName,
      );
    });
  }
}