import 'package:chat_app/dependencies.dart' as di;
import 'package:chat_app/features/auth/domain/usecases/check_login_status_usecase.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/auth/presentation/views/login_view.dart';
import 'package:chat_app/features/auth/presentation/views/otp_verification_view.dart';
import 'package:chat_app/features/chat/presentation/views/chat_view.dart';
import 'package:chat_app/features/friends/data/services/friends_cache_service.dart';
import 'package:chat_app/features/friends/presentation/views/all_users_view.dart';
import 'package:chat_app/features/friends/presentation/views/friends_view.dart';
import 'package:chat_app/features/friends/presentation/views/search_users_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;
  
  const AuthWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          FriendsCacheService.clearCache();
          context.go('/');
        } else if (state is AuthSuccess) {
          context.go('/friends');
        }
      },
      child: child,
    );
  }
}

class AppRouter {
  late final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final isLoggedIn = await di.sl<CheckLoginStatusUseCase>().call();
      
      if (isLoggedIn && state.matchedLocation == '/') {
        return '/friends';
      }
      
      if (!isLoggedIn && state.matchedLocation != '/' && state.matchedLocation != '/otp-verification') {
        return '/';
      }
      
      return null; 
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'login',
        builder: (context, state) => const AuthWrapper(child: LoginView()),
      ),
      GoRoute(
        path: '/all-users',
        name: 'all-users',
        builder: (context, state) => const AuthWrapper(child: AllUsersView()),
      ),
      GoRoute(
        path: '/otp-verification',
        name: 'otp-verification',
        builder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          return AuthWrapper(child: OtpVerificationView(extraData: extraData));
        },
      ),
      GoRoute(
        path: '/friends',
        name: 'friends',
        builder: (context, state) => const AuthWrapper(child: FriendsView()),
      ),
      GoRoute(
        path: '/search-users',
        name: 'search-users',
        builder: (context, state) => const AuthWrapper(child: SearchUsersView()),
      ),
      GoRoute(
        path: '/chat/:friendId',
        name: 'chat',
        builder: (context, state) {
          final friendId = state.pathParameters['friendId']!;
          return AuthWrapper(child: ChatView(friendId: friendId));
        },
      ),
    ],
  );
}