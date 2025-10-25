part of 'friends_bloc.dart';

abstract class FriendsState extends Equatable {
  const FriendsState();

  @override
  List<Object> get props => [];
}

class FriendsInitial extends FriendsState {}

class FriendsLoading extends FriendsState {}

class FriendsDataLoaded extends FriendsState {
  final List<Map<String, dynamic>> friends;
  final List<Map<String, dynamic>> friendRequests;
  final List<Map<String, dynamic>> users;
  final bool isFromCache;

  const FriendsDataLoaded({
    required this.friends,
    required this.friendRequests,
    required this.users,
    this.isFromCache = false,
  });

  @override
  List<Object> get props => [friends, friendRequests, users, isFromCache];
}

class UsersLoaded extends FriendsState {
  final List<Map<String, dynamic>> users;
  final bool isFromCache;

  const UsersLoaded(this.users, {this.isFromCache = false});

  @override
  List<Object> get props => [users, isFromCache];
}

class FriendRequestsLoaded extends FriendsState {
  final List<Map<String, dynamic>> friendRequests;
  final bool isFromCache;

  const FriendRequestsLoaded(this.friendRequests, {this.isFromCache = false});

  @override
  List<Object> get props => [friendRequests, isFromCache];
}

class FriendsLoaded extends FriendsState {
  final List<Map<String, dynamic>> friends;
  final bool isFromCache;

  const FriendsLoaded(this.friends, {this.isFromCache = false});

  @override
  List<Object> get props => [friends, isFromCache];
}

class FriendRequestSent extends FriendsState {}

class FriendRequestAccepted extends FriendsState {}

class FriendRequestRejected extends FriendsState {}

class FriendRequestCancelled extends FriendsState {}

class FriendsError extends FriendsState {
  final String message;

  const FriendsError(this.message);

  @override
  List<Object> get props => [message];
}

class UsersSearched extends FriendsState {
  final List<Map<String, dynamic>> users;

  const UsersSearched(this.users);

  @override
  List<Object> get props => [users];
}