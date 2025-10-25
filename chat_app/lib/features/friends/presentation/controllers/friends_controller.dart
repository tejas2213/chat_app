import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/friends_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class FriendsController {
  static void handleFriendsState(BuildContext context, FriendsState state) {
    if (state is FriendRequestSent) {
      _showSuccessSnackBar(context, 'Friend request sent');
    } else if (state is FriendRequestAccepted) {
      _showSuccessSnackBar(context, 'Friend request accepted');
    } else if (state is FriendRequestRejected) {
      _showInfoSnackBar(context, 'Friend request rejected');
    } else if (state is FriendsError) {
      _showErrorSnackBar(context, state.message);
    }
  }

  static void loadAllData(BuildContext context) {
    context.read<FriendsBloc>().add(LoadAllDataEvent());
  }

  static void loadFriends(BuildContext context) {
    context.read<FriendsBloc>().add(LoadFriendsEvent());
  }

  static void loadFriendRequests(BuildContext context) {
    context.read<FriendsBloc>().add(LoadFriendRequestsEvent());
  }

  static void loadUsers(BuildContext context) {
    context.read<FriendsBloc>().add(LoadUsersEvent());
  }

  static void sendFriendRequest(BuildContext context, String toUserId) {
    context.read<FriendsBloc>().add(SendFriendRequestEvent(toUserId));
  }

  static void acceptFriendRequest(BuildContext context, String requestId) {
    context.read<FriendsBloc>().add(AcceptFriendRequestEvent(requestId));
  }

  static void rejectFriendRequest(BuildContext context, String requestId) {
    context.read<FriendsBloc>().add(RejectFriendRequestEvent(requestId));
  }

  static void searchUsers(BuildContext context, String query) {
    context.read<FriendsBloc>().add(SearchUsersEvent(query));
  }

  static Future<void> handleLogout(BuildContext context) async {
    try {
      if (context.mounted) {
        _showLoadingSnackBar(context, 'Logging out...');
      }
      
      context.read<AuthBloc>().add(const LogoutEvent());
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Logout failed: $e');
      }
    }
  }

  static void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              handleLogout(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  static void navigateToSearchUsers(BuildContext context) {
    context.push('/search-users');
  }

  static void navigateToChat(BuildContext context, String friendId, String friendName) {
    context.push('/chat/$friendId', extra: {
      'friendName': friendName,
    });
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  static void _showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }

  static void _showLoadingSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
