import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/friends/data/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/friends_bloc.dart';
import '../widgets/loading_button_widget.dart';
import '../widgets/error_retry_widget.dart';

class FriendsView extends StatefulWidget {
  const FriendsView({super.key});

  @override
  State<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends State<FriendsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        if (_tabController.index == 0) {
          context.read<FriendsBloc>().add(LoadFriendsEvent());
        } else if (_tabController.index == 1) {
          context.read<FriendsBloc>().add(LoadFriendRequestsEvent());
        } else if (_tabController.index == 2) {
          context.read<FriendsBloc>().add(LoadUsersEvent());
        }
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendsBloc>().add(LoadAllDataEvent());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Logging out...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      context.read<AuthBloc>().add(const LogoutEvent());
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search-users'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
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
                        _handleLogout();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Friends'),
            Tab(text: 'Requests'),
            Tab(text: 'All Users'),
          ],
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocListener<FriendsBloc, FriendsState>(
          listener: (context, state) {
            if (state is FriendRequestSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Friend request sent'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is FriendRequestAccepted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Friend request accepted'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is FriendRequestRejected) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Friend request rejected'),
                  backgroundColor: Colors.orange,
                ),
              );
            } else if (state is FriendsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildFriendsTab(),
              _buildRequestsTab(),
              _buildAllUsersTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsTab() {
    return BlocBuilder<FriendsBloc, FriendsState>(
      builder: (context, state) {
        if (state is FriendsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is FriendsDataLoaded) {
          final friends = state.friends;
          return _buildFriendsContent(friends, state.isFromCache);
        } else if (state is FriendsDataLoadedWithAction) {
          final friends = state.friends;
          return _buildFriendsContent(friends, state.isFromCache);
        } else if (state is FriendsLoaded) {
          final friends = state.friends;
          return _buildFriendsContent(friends, state.isFromCache);
        } else if (state is FriendsError) {
          return ErrorRetryWidget(
            message: state.message,
            onRetry: () {
              context.read<FriendsBloc>().add(LoadFriendsEvent());
            },
          );
        }
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading friends...'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFriendItem(Map<String, dynamic> friend) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _userService.getUserStream(friend['friendId']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Loading...'),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('User not found'),
          );
        }

        final user = snapshot.data!;
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(user['name'] ?? user['phoneNumber']),
          subtitle: Text(user['phoneNumber']),
          trailing: ElevatedButton(
            onPressed: () {
              context.push('/chat/${friend['friendId']}', extra: {
                'friendName': user['name'] ?? user['phoneNumber'],
              });
            },
            child: const Text('Chat'),
          ),
        );
      },
    );
  }

  Widget _buildRequestsTab() {
    return BlocBuilder<FriendsBloc, FriendsState>(
      builder: (context, state) {
        if (state is FriendsLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading friend requests...'),
              ],
            ),
          );
        } else if (state is FriendsDataLoaded) {
          final requests = state.friendRequests;
          return _buildRequestsContent(requests, state.isFromCache);
        } else if (state is FriendsDataLoadedWithAction) {
          final requests = state.friendRequests;
          return _buildRequestsContent(requests, state.isFromCache);
        } else if (state is FriendRequestsLoaded) {
          final requests = state.friendRequests;
          return _buildRequestsContent(requests, state.isFromCache);
        } else if (state is FriendRequestsLoadedWithAction) {
          final requests = state.friendRequests;
          return _buildRequestsContent(requests, state.isFromCache);
        } else if (state is FriendsError) {
          return ErrorRetryWidget(
            message: state.message,
            onRetry: () {
              context.read<FriendsBloc>().add(LoadFriendRequestsEvent());
            },
          );
        }
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading friend requests...'),
              SizedBox(height: 8),
              Text(
                'If you have pending requests, they will appear here',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestItem(Map<String, dynamic> request) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _userService.getUserStream(request['fromUserId']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Loading...'),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('User not found'),
          );
        }

        final user = snapshot.data!;
        return BlocBuilder<FriendsBloc, FriendsState>(
          builder: (context, state) {
            bool isAccepting = false;
            bool isRejecting = false;
            
            // Check for loading states in different state types
            if (state is FriendRequestAccepting && state.requestId == request['id']) {
              isAccepting = true;
            } else if (state is FriendRequestRejecting && state.requestId == request['id']) {
              isRejecting = true;
            } else if (state is FriendsDataLoadedWithAction && 
                       state.loadingRequestId == request['id']) {
              isAccepting = state.actionType == 'accepting';
              isRejecting = state.actionType == 'rejecting';
            } else if (state is FriendRequestsLoadedWithAction && 
                       state.loadingRequestId == request['id']) {
              isAccepting = state.actionType == 'accepting';
              isRejecting = state.actionType == 'rejecting';
            }
            
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user['name'] ?? user['phoneNumber']),
              subtitle: Text(user['phoneNumber']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoadingIconButtonWidget(
                    icon: Icons.check,
                    color: Colors.green,
                    isLoading: isAccepting,
                    onPressed: isAccepting || isRejecting ? null : () {
                      context.read<FriendsBloc>().add(
                        AcceptFriendRequestEvent(request['id']),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  LoadingIconButtonWidget(
                    icon: Icons.close,
                    color: Colors.red,
                    isLoading: isRejecting,
                    onPressed: isAccepting || isRejecting ? null : () {
                      context.read<FriendsBloc>().add(
                        RejectFriendRequestEvent(request['id']),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRequestsContent(List<Map<String, dynamic>> requests, bool isFromCache) {
    if (requests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No pending friend requests',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'When someone sends you a friend request, it will appear here',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FriendsBloc>().add(LoadFriendRequestsEvent());
      },
      child: Stack(
        children: [
          ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _buildRequestItem(request);
            },
          ),
          if (isFromCache)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Cached',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAllUsersTab() {
    return BlocBuilder<FriendsBloc, FriendsState>(
      builder: (context, state) {
        if (state is FriendsLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading users...'),
              ],
            ),
          );
        } else if (state is FriendsDataLoaded) {
          final users = state.users;
          return _buildUsersContent(users, state.isFromCache);
        } else if (state is FriendsDataLoadedWithAction) {
          final users = state.users;
          return _buildUsersContent(users, state.isFromCache);
        } else if (state is UsersLoaded) {
          final users = state.users;
          return _buildUsersContent(users, state.isFromCache);
        } else if (state is UsersLoadedWithAction) {
          final users = state.users;
          return _buildUsersContent(users, state.isFromCache);
        } else if (state is FriendsError) {
          return ErrorRetryWidget(
            message: state.message,
            onRetry: () {
              context.read<FriendsBloc>().add(LoadUsersEvent());
            },
          );
        }
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading users...'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsersContent(List<Map<String, dynamic>> users, bool isFromCache) {
    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No other users found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'All users will appear here when they join the app',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FriendsBloc>().add(LoadUsersEvent());
      },
      child: Stack(
        children: [
          ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserItem(user);
            },
          ),
          if (isFromCache)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Cached',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserItem(Map<String, dynamic> user) {
    final bool hasPendingRequest = user['hasPendingRequest'] ?? false;
    final bool isFriend = user['isFriend'] ?? false;
    
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(user['name'] ?? user['phoneNumber']),
      subtitle: Text(user['phoneNumber']),
      trailing: _buildUserActionButton(user, hasPendingRequest, isFriend),
    );
  }

  Widget _buildUserActionButton(Map<String, dynamic> user, bool hasPendingRequest, bool isFriend) {
    if (isFriend) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Friends',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      );
    } else if (hasPendingRequest) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Request Sent',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      );
    } else {
      return BlocBuilder<FriendsBloc, FriendsState>(
        builder: (context, state) {
          bool isSending = false;
          
          if (state is FriendRequestSending && state.userId == user['uid']) {
            isSending = true;
          } else if (state is FriendsDataLoadedWithAction && 
                     state.loadingUserId == user['uid'] && 
                     state.actionType == 'sending') {
            isSending = true;
          } else if (state is UsersLoadedWithAction && 
                     state.loadingUserId == user['uid'] && 
                     state.actionType == 'sending') {
            isSending = true;
          }
          
          return LoadingButtonWidget(
            text: 'Send Request',
            isLoading: isSending,
            onPressed: isSending ? null : () {
              context.read<FriendsBloc>().add(
                SendFriendRequestEvent(user['uid']),
              );
            },
            width: 120,
            height: 36,
          );
        },
      );
    }
  }

  Widget _buildFriendsContent(List<Map<String, dynamic>> friends, bool isFromCache) {
    if (friends.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No friends yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Send some friend requests to start building your network!',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FriendsBloc>().add(LoadFriendsEvent());
      },
      child: Stack(
        children: [
          ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return _buildFriendItem(friend);
            },
          ),
          if (isFromCache)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Cached',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}