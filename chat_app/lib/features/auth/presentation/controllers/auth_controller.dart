import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';

class AuthController {
  static void handleAuthState(BuildContext context, AuthState state) {
    if (state is OtpSent) {
      _navigateToOtpVerification(context, state.verificationId);
    } else if (state is AuthSuccess) {
      _navigateToFriends(context);
    } else if (state is AuthError) {
      _showErrorSnackBar(context, state.message);
    } else if (state is LogoutSuccess) {
      _navigateToLogin(context);
    }
  }

  static void sendOtp(BuildContext context, String phoneNumber) {
    context.read<AuthBloc>().add(SendOtpEvent(phoneNumber));
  }

  static void verifyOtp(BuildContext context, String otp, String verificationId) {
    context.read<AuthBloc>().add(VerifyOtpEvent(verificationId, otp));
  }

  static void logout(BuildContext context) {
    context.read<AuthBloc>().add(const LogoutEvent());
  }

  static void checkAuthStatus(BuildContext context) {
    context.read<AuthBloc>().add(const CheckAuthStatusEvent());
  }

  static void _navigateToOtpVerification(BuildContext context, String verificationId) {
    context.push('/otp-verification', extra: {
      'verificationId': verificationId,
    });
  }

  static void _navigateToFriends(BuildContext context) {
    context.go('/friends');
  }

  static void _navigateToLogin(BuildContext context) {
    context.go('/login');
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
