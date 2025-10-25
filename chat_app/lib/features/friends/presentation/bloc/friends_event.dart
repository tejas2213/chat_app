part of 'friends_bloc.dart';

abstract class FriendsEvent extends Equatable {
  const FriendsEvent();

  @override
  List<Object> get props => [];
}

class LoadAllDataEvent extends FriendsEvent {}

class LoadUsersEvent extends FriendsEvent {}

class LoadFriendRequestsEvent extends FriendsEvent {}

class LoadFriendsEvent extends FriendsEvent {}

class SendFriendRequestEvent extends FriendsEvent {
  final String toUserId;

  const SendFriendRequestEvent(this.toUserId);

  @override
  List<Object> get props => [toUserId];
}

class AcceptFriendRequestEvent extends FriendsEvent {
  final String requestId;

  const AcceptFriendRequestEvent(this.requestId);

  @override
  List<Object> get props => [requestId];
}

class RejectFriendRequestEvent extends FriendsEvent {
  final String requestId;

  const RejectFriendRequestEvent(this.requestId);

  @override
  List<Object> get props => [requestId];
}

class CancelFriendRequestEvent extends FriendsEvent {
  final String requestId;

  const CancelFriendRequestEvent(this.requestId);

  @override
  List<Object> get props => [requestId];
}

class SearchUsersEvent extends FriendsEvent {
  final String query;

  const SearchUsersEvent(this.query);

  @override
  List<Object> get props => [query];
}