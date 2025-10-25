import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/friends_bloc.dart';

class AllUsersView extends StatefulWidget {
  const AllUsersView({super.key});

  @override
  State<AllUsersView> createState() => _AllUsersViewState();
}

class _AllUsersViewState extends State<AllUsersView> {
  @override
  void initState() {
    super.initState();
    context.read<FriendsBloc>().add(LoadUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<FriendsBloc, FriendsState>(
        listener: (context, state) {
          if (state is FriendRequestSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Friend request sent'),
                backgroundColor: Colors.green,
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
        child: BlocBuilder<FriendsBloc, FriendsState>(
          builder: (context, state) {
            if (state is FriendsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UsersLoaded) {
              final users = state.users;
              if (users.isEmpty) {
                return const Center(child: Text('No users found'));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<FriendsBloc>().add(LoadUsersEvent());
                },
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user['profileImage'] != null
                            ? NetworkImage(user['profileImage'])
                            : null,
                        child: user['profileImage'] == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(user['name'] ?? user['phoneNumber']),
                      subtitle: Text(user['phoneNumber']),
                      trailing: ElevatedButton(
                        onPressed: () {
                          context.read<FriendsBloc>().add(
                            SendFriendRequestEvent(user['uid']),
                          );
                        },
                        child: const Text('Add Friend'),
                      ),
                    );
                  },
                ),
              );
            } else if (state is FriendsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<FriendsBloc>().add(LoadUsersEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<FriendsBloc>().add(LoadUsersEvent());
                },
                child: const Text('Load Users'),
              ),
            );
          },
        ),
      ),
    );
  }
}