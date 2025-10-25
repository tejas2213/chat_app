import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/friends_bloc.dart';

class SearchUsersView extends StatefulWidget {
  const SearchUsersView({super.key});

  @override
  State<SearchUsersView> createState() => _SearchUsersViewState();
}

class _SearchUsersViewState extends State<SearchUsersView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users'),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search by phone number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      if (_searchController.text.trim().isNotEmpty) {
                        context.read<FriendsBloc>().add(
                          SearchUsersEvent(_searchController.text.trim()),
                        );
                      }
                    },
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    context.read<FriendsBloc>().add(
                      SearchUsersEvent(value.trim()),
                    );
                  }
                },
              ),
            ),
            BlocBuilder<FriendsBloc, FriendsState>(
              builder: (context, state) {
                if (state is FriendsLoading) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is UsersSearched) {
                  if (state.users.isEmpty) {
                    return const Expanded(
                      child: Center(
                        child: Text('No users found'),
                      ),
                    );
                  }
                  return Expanded(
                    child: ListView.builder(
                      itemCount: state.users.length,
                      itemBuilder: (context, index) {
                        final user = state.users[index];
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
                  return Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.message,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (_searchController.text.trim().isNotEmpty) {
                                context.read<FriendsBloc>().add(
                                  SearchUsersEvent(_searchController.text.trim()),
                                );
                              }
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const Expanded(
                  child: Center(
                    child: Text('Enter phone number to search'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}