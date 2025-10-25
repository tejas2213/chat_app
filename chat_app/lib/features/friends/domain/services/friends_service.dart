import 'package:chat_app/features/friends/data/services/friends_cache_service.dart';
import 'package:chat_app/features/friends/domain/usecases/get_users_usecase.dart';
import 'package:chat_app/features/friends/domain/usecases/get_friend_requests_usecase.dart';
import 'package:chat_app/features/friends/domain/usecases/get_friends_usecase.dart';
import 'package:chat_app/features/friends/domain/usecases/send_friend_request_usecase.dart';
import 'package:chat_app/features/friends/domain/usecases/accept_friend_request_usecase.dart';
import 'package:chat_app/features/friends/domain/usecases/reject_friend_request_usecase.dart';
import 'package:chat_app/features/friends/domain/usecases/search_users_usecase.dart';

abstract class FriendsService {
  Future<List<Map<String, dynamic>>> getFriends();
  Future<List<Map<String, dynamic>>> getFriendRequests();
  Future<List<Map<String, dynamic>>> getUsers();
  Future<void> sendFriendRequest(String toUserId);
  Future<void> acceptFriendRequest(String requestId);
  Future<void> rejectFriendRequest(String requestId);
  Future<List<Map<String, dynamic>>> searchUsers(String query);
  Future<List<Map<String, dynamic>>> getCachedFriends();
  Future<List<Map<String, dynamic>>> getCachedFriendRequests();
  Future<List<Map<String, dynamic>>> getCachedUsers();
  Future<bool> isCacheValid();
  Stream<List<Map<String, dynamic>>> getFriendsStream();
  Stream<List<Map<String, dynamic>>> getFriendRequestsStream();
  Stream<List<Map<String, dynamic>>> getUsersStream();
}

class FriendsServiceImpl implements FriendsService {
  final GetUsersUseCase _getUsers;
  final GetFriendRequestsUseCase _getFriendRequests;
  final GetFriendsUseCase _getFriends;
  final SendFriendRequestUseCase _sendFriendRequest;
  final AcceptFriendRequestUseCase _acceptFriendRequest;
  final RejectFriendRequestUseCase _rejectFriendRequest;
  final SearchUsersUseCase _searchUsers;

  FriendsServiceImpl({
    required GetUsersUseCase getUsers,
    required GetFriendRequestsUseCase getFriendRequests,
    required GetFriendsUseCase getFriends,
    required SendFriendRequestUseCase sendFriendRequest,
    required AcceptFriendRequestUseCase acceptFriendRequest,
    required RejectFriendRequestUseCase rejectFriendRequest,
    required SearchUsersUseCase searchUsers,
  }) : _getUsers = getUsers,
       _getFriendRequests = getFriendRequests,
       _getFriends = getFriends,
       _sendFriendRequest = sendFriendRequest,
       _acceptFriendRequest = acceptFriendRequest,
       _rejectFriendRequest = rejectFriendRequest,
       _searchUsers = searchUsers;

  @override
  Future<List<Map<String, dynamic>>> getFriends() async {
    throw UnimplementedError('Use getFriendsStream() instead');
  }

  @override
  Future<List<Map<String, dynamic>>> getFriendRequests() async {
    throw UnimplementedError('Use getFriendRequestsStream() instead');
  }

  @override
  Future<List<Map<String, dynamic>>> getUsers() async {
    throw UnimplementedError('Use getUsersStream() instead');
  }

  @override
  Future<void> sendFriendRequest(String toUserId) async {
    final result = await _sendFriendRequest(toUserId);
    result.fold(
      (error) => throw Exception(error),
      (_) => {},
    );
  }

  @override
  Future<void> acceptFriendRequest(String requestId) async {
    final result = await _acceptFriendRequest(requestId);
    result.fold(
      (error) => throw Exception(error),
      (_) => {},
    );
  }

  @override
  Future<void> rejectFriendRequest(String requestId) async {
    final result = await _rejectFriendRequest(requestId);
    result.fold(
      (error) => throw Exception(error),
      (_) => {},
    );
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final result = await _searchUsers(query);
    return result.fold(
      (error) => throw Exception(error),
      (users) => users,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedFriends() async {
    return await FriendsCacheService.getCachedFriends();
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedFriendRequests() async {
    return await FriendsCacheService.getCachedFriendRequests();
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedUsers() async {
    return await FriendsCacheService.getCachedUsers();
  }

  @override
  Future<bool> isCacheValid() async {
    return await FriendsCacheService.isCacheValid();
  }

  @override
  Stream<List<Map<String, dynamic>>> getFriendsStream() {
    return _getFriends();
  }

  @override
  Stream<List<Map<String, dynamic>>> getFriendRequestsStream() {
    return _getFriendRequests();
  }

  @override
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _getUsers();
  }
}
