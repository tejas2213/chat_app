import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRemoteDataSource {
  Future<String> sendOtp(String phoneNumber);
  Future<User> verifyOtp(String verificationId, String otp);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<String> sendOtp(String phoneNumber) async {
    final completer = Completer<String>();
    
    try {
      final formattedPhoneNumber = phoneNumber.startsWith('+') 
          ? phoneNumber 
          : '+$phoneNumber';

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
          } catch (e) {}
        },
        verificationFailed: (FirebaseAuthException e) {
          completer.completeError('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
        timeout: const Duration(seconds: 60),
      );

      return await completer.future;
    } catch (e) {
      if (!completer.isCompleted) {
        completer.completeError('Failed to send OTP: $e');
      }
      rethrow;
    }
  }

  @override
  Future<User> verifyOtp(String verificationId, String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        throw Exception('User authentication failed');
      }

      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      throw Exception('OTP verification failed: ${e.message}');
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }
}