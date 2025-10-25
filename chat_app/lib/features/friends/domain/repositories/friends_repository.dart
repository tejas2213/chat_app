abstract class FriendsRepository {
  Stream<List<Map<String, dynamic>>> getUsers();
  Stream<List<Map<String, dynamic>>> getFriendRequests();
  Stream<List<Map<String, dynamic>>> getFriends();
  Future<void> sendFriendRequest(String toUserId);
  Future<void> acceptFriendRequest(String requestId);
  Future<void> rejectFriendRequest(String requestId);
  Future<void> cancelFriendRequest(String requestId);
  Future<List<Map<String, dynamic>>> searchUsers(String query);
}