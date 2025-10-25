import 'package:chat_app/features/friends/data/datasources/friends_remote_data_source.dart';
import 'package:chat_app/features/friends/data/services/friends_cache_service.dart';
import 'package:chat_app/features/friends/domain/repositories/friends_repository.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsRemoteDataSource remoteDataSource;

  FriendsRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<Map<String, dynamic>>> getUsers() async* {
    final cachedUsers = await FriendsCacheService.getCachedUsers();
    if (cachedUsers.isNotEmpty) {
      yield cachedUsers;
    }
    
    await for (final users in remoteDataSource.getUsers()) {
      if (users.isNotEmpty) {
        await FriendsCacheService.cacheUsers(users);
      }
      yield users;
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> getFriendRequests() async* {
    final cachedRequests = await FriendsCacheService.getCachedFriendRequests();
    if (cachedRequests.isNotEmpty) {
      yield cachedRequests;
    }
    
    await for (final requests in remoteDataSource.getFriendRequests()) {
      if (requests.isNotEmpty) {
        await FriendsCacheService.cacheFriendRequests(requests);
      }
      yield requests;
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> getFriends() async* {
    final cachedFriends = await FriendsCacheService.getCachedFriends();
    if (cachedFriends.isNotEmpty) {
      yield cachedFriends;
    }
    
    await for (final friends in remoteDataSource.getFriends()) {
      if (friends.isNotEmpty) {
        await FriendsCacheService.cacheFriends(friends);
      }
      yield friends;
    }
  }

  @override
  Future<void> sendFriendRequest(String toUserId) async {
    return await remoteDataSource.sendFriendRequest(toUserId);
  }

  @override
  Future<void> acceptFriendRequest(String requestId) async {
    return await remoteDataSource.acceptFriendRequest(requestId);
  }

  @override
  Future<void> rejectFriendRequest(String requestId) async {
    return await remoteDataSource.rejectFriendRequest(requestId);
  }

  @override
  Future<void> cancelFriendRequest(String requestId) async {
    return await remoteDataSource.cancelFriendRequest(requestId);
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    return await remoteDataSource.searchUsers(query);
  }
}
