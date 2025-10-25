import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:chat_app/features/friends/domain/services/friends_service.dart';

part 'friends_event.dart';
part 'friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final FriendsService _friendsService;

  FriendsBloc({required FriendsService friendsService}) 
      : _friendsService = friendsService,
        super(FriendsInitial()) {
    on<LoadAllDataEvent>(_onLoadAllData);
    on<LoadUsersEvent>(_onLoadUsers);
    on<LoadFriendRequestsEvent>(_onLoadFriendRequests);
    on<LoadFriendsEvent>(_onLoadFriends);
    on<SendFriendRequestEvent>(_onSendFriendRequest);
    on<AcceptFriendRequestEvent>(_onAcceptFriendRequest);
    on<RejectFriendRequestEvent>(_onRejectFriendRequest);
    on<SearchUsersEvent>(_onSearchUsers);
  }

  void _onLoadAllData(LoadAllDataEvent event, Emitter<FriendsState> emit) async {
    try {
      final cachedFriends = await _friendsService.getCachedFriends();
      final cachedRequests = await _friendsService.getCachedFriendRequests();
      final cachedUsers = await _friendsService.getCachedUsers();
      
      if (cachedFriends.isNotEmpty || cachedRequests.isNotEmpty || cachedUsers.isNotEmpty) {
        emit(FriendsDataLoaded(
          friends: cachedFriends,
          friendRequests: cachedRequests,
          users: cachedUsers,
          isFromCache: true,
        ));
      } else {
        emit(FriendsLoading());
      }
      
      final friendsStream = _friendsService.getFriendsStream();
      
      List<Map<String, dynamic>> currentFriends = cachedFriends;
      List<Map<String, dynamic>> currentRequests = cachedRequests;
      List<Map<String, dynamic>> currentUsers = cachedUsers;
      
      await emit.forEach(
        friendsStream,
        onData: (friends) {
          currentFriends = friends;
          return FriendsDataLoaded(
            friends: currentFriends,
            friendRequests: currentRequests,
            users: currentUsers,
            isFromCache: false,
          );
        },
        onError: (error, _) => FriendsError(error.toString()),
      );
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  void _onLoadUsers(LoadUsersEvent event, Emitter<FriendsState> emit) async {
    if (state is UsersLoaded) {
      return;
    }
    
    try {
      final cachedUsers = await _friendsService.getCachedUsers();
      if (cachedUsers.isNotEmpty) {
        emit(UsersLoaded(cachedUsers, isFromCache: true));
      }
      
      final hasValidCache = await _friendsService.isCacheValid();
      if (!hasValidCache && cachedUsers.isEmpty) {
        emit(FriendsLoading());
      }
      
      final usersStream = _friendsService.getUsersStream();
      await emit.forEach(
        usersStream,
        onData: (users) => UsersLoaded(users, isFromCache: false),
        onError: (error, _) => FriendsError(error.toString()),
      );
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  void _onLoadFriendRequests(LoadFriendRequestsEvent event, Emitter<FriendsState> emit) async {
    try {
      final cachedRequests = await _friendsService.getCachedFriendRequests();
      if (cachedRequests.isNotEmpty) {
        emit(FriendRequestsLoaded(cachedRequests, isFromCache: true));
      }
      
      final hasValidCache = await _friendsService.isCacheValid();
      if (!hasValidCache && cachedRequests.isEmpty) {
        emit(FriendsLoading());
      }
      
      final requestsStream = _friendsService.getFriendRequestsStream();
      await emit.forEach(
        requestsStream,
        onData: (requests) => FriendRequestsLoaded(requests, isFromCache: false),
        onError: (error, _) => FriendsError(error.toString()),
      );
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  void _onLoadFriends(LoadFriendsEvent event, Emitter<FriendsState> emit) async {
    try {
      final cachedFriends = await _friendsService.getCachedFriends();
      if (cachedFriends.isNotEmpty) {
        emit(FriendsLoaded(cachedFriends, isFromCache: true));
      }
      
      final hasValidCache = await _friendsService.isCacheValid();
      if (!hasValidCache && cachedFriends.isEmpty) {
        emit(FriendsLoading());
      }
      
      final friendsStream = _friendsService.getFriendsStream();
      await emit.forEach(
        friendsStream,
        onData: (friends) => FriendsLoaded(friends, isFromCache: false),
        onError: (error, _) => FriendsError(error.toString()),
      );
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  void _onSendFriendRequest(SendFriendRequestEvent event, Emitter<FriendsState> emit) async {
    final currentState = state;
    if (currentState is FriendsDataLoaded) {
      emit(FriendsDataLoadedWithAction(
        friends: currentState.friends,
        friendRequests: currentState.friendRequests,
        users: currentState.users,
        isFromCache: currentState.isFromCache,
        loadingUserId: event.toUserId,
        actionType: 'sending',
      ));
    } else if (currentState is UsersLoaded) {
      emit(UsersLoadedWithAction(
        users: currentState.users,
        isFromCache: currentState.isFromCache,
        loadingUserId: event.toUserId,
        actionType: 'sending',
      ));
    } else {
      emit(FriendRequestSending(event.toUserId));
    }
    
    try {
      await _friendsService.sendFriendRequest(event.toUserId)
          .timeout(const Duration(seconds: 10));
      
      if (currentState is FriendsDataLoaded) {
        emit(FriendsDataLoaded(
          friends: currentState.friends,
          friendRequests: currentState.friendRequests,
          users: currentState.users,
          isFromCache: false,
        ));
      } else if (currentState is UsersLoaded) {
        final usersStream = _friendsService.getUsersStream();
        await emit.forEach(
          usersStream,
          onData: (users) => UsersLoaded(users, isFromCache: false),
          onError: (error, _) => FriendsError(error.toString()),
        );
      } else {
        emit(FriendRequestSent());
      }
    } on TimeoutException {
      emit(const FriendsError('Request timed out. Please check your connection and try again.'));
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  void _onAcceptFriendRequest(AcceptFriendRequestEvent event, Emitter<FriendsState> emit) async {
    final currentState = state;
    if (currentState is FriendsDataLoaded) {
      emit(FriendsDataLoadedWithAction(
        friends: currentState.friends,
        friendRequests: currentState.friendRequests,
        users: currentState.users,
        isFromCache: currentState.isFromCache,
        loadingRequestId: event.requestId,
        actionType: 'accepting',
      ));
    } else if (currentState is FriendRequestsLoaded) {
      emit(FriendRequestsLoadedWithAction(
        friendRequests: currentState.friendRequests,
        isFromCache: currentState.isFromCache,
        loadingRequestId: event.requestId,
        actionType: 'accepting',
      ));
    } else {
      emit(FriendRequestAccepting(event.requestId));
    }
    
    try {
      await _friendsService.acceptFriendRequest(event.requestId)
          .timeout(const Duration(seconds: 10));
      
      if (currentState is FriendsDataLoaded) {
        emit(FriendsDataLoaded(
          friends: currentState.friends,
          friendRequests: currentState.friendRequests,
          users: currentState.users,
          isFromCache: false,
        ));
      } else if (currentState is FriendRequestsLoaded) {
        final requestsStream = _friendsService.getFriendRequestsStream();
        await emit.forEach(
          requestsStream,
          onData: (requests) => FriendRequestsLoaded(requests, isFromCache: false),
          onError: (error, _) => FriendsError(error.toString()),
        );
      } else {
        emit(FriendRequestAccepted());
      }
    } on TimeoutException {
      emit(const FriendsError('Request timed out. Please check your connection and try again.'));
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  void _onRejectFriendRequest(RejectFriendRequestEvent event, Emitter<FriendsState> emit) async {
    final currentState = state;
    if (currentState is FriendsDataLoaded) {
      emit(FriendsDataLoadedWithAction(
        friends: currentState.friends,
        friendRequests: currentState.friendRequests,
        users: currentState.users,
        isFromCache: currentState.isFromCache,
        loadingRequestId: event.requestId,
        actionType: 'rejecting',
      ));
    } else if (currentState is FriendRequestsLoaded) {
      emit(FriendRequestsLoadedWithAction(
        friendRequests: currentState.friendRequests,
        isFromCache: currentState.isFromCache,
        loadingRequestId: event.requestId,
        actionType: 'rejecting',
      ));
    } else {
      emit(FriendRequestRejecting(event.requestId));
    }
    
    try {
      await _friendsService.rejectFriendRequest(event.requestId)
          .timeout(const Duration(seconds: 10));
      
      if (currentState is FriendsDataLoaded) {
        emit(FriendsDataLoaded(
          friends: currentState.friends,
          friendRequests: currentState.friendRequests,
          users: currentState.users,
          isFromCache: false,
        ));
      } else if (currentState is FriendRequestsLoaded) {
        final requestsStream = _friendsService.getFriendRequestsStream();
        await emit.forEach(
          requestsStream,
          onData: (requests) => FriendRequestsLoaded(requests, isFromCache: false),
          onError: (error, _) => FriendsError(error.toString()),
        );
      } else {
        emit(FriendRequestRejected());
      }
    } on TimeoutException {
      emit(const FriendsError('Request timed out. Please check your connection and try again.'));
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  void _onSearchUsers(SearchUsersEvent event, Emitter<FriendsState> emit) async {
    emit(FriendsLoading());
    try {
      final users = await _friendsService.searchUsers(event.query);
      emit(UsersSearched(users));
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }
}