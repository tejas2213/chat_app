import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'data_transformation_service.dart';
import 'error_handler.dart';

class FriendsCacheService {
  static const String _friendsKey = 'cached_friends';
  static const String _friendRequestsKey = 'cached_friend_requests';
  static const String _usersKey = 'cached_users';
  static const String _cacheTimestampKey = 'cache_timestamp';
  static const Duration _cacheValidityDuration = Duration(minutes: 10);

  static Future<void> cacheFriends(List<Map<String, dynamic>> friends) async {
    await ErrorHandler.handleCacheError(
      'cacheFriends',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final processedFriends = friends.map((friend) => DataTransformationService.transformFirebaseData(friend)).toList();
        final friendsJson = jsonEncode(processedFriends);
        await prefs.setString(_friendsKey, friendsJson);
        await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
      },
      null,
    );
  }

  static Future<List<Map<String, dynamic>>> getCachedFriends() async {
    return await ErrorHandler.handleCacheError(
      'getCachedFriends',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final friendsJson = prefs.getString(_friendsKey);
        final timestamp = prefs.getInt(_cacheTimestampKey) ?? 0;
        
        ErrorHandler.logSuccess('getCachedFriends', {
          'hasData': friendsJson != null,
          'timestamp': timestamp,
          'isValid': timestamp > 0 && DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp)) <= _cacheValidityDuration,
        });
        
        if (friendsJson == null || timestamp == 0) {
          return <Map<String, dynamic>>[];
        }

        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheValidityDuration) {
          ErrorHandler.logWarning('getCachedFriends', 'Cache expired, clearing');
          await clearCache();
          return <Map<String, dynamic>>[];
        }

        final List<dynamic> friendsList = jsonDecode(friendsJson);
        final friends = friendsList.cast<Map<String, dynamic>>();
        return friends.map((friend) => DataTransformationService.transformToFirebaseData(friend)).toList();
      },
      <Map<String, dynamic>>[],
    );
  }

  static Future<void> cacheFriendRequests(List<Map<String, dynamic>> requests) async {
    await ErrorHandler.handleCacheError(
      'cacheFriendRequests',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final processedRequests = requests.map((request) => DataTransformationService.transformFirebaseData(request)).toList();
        final requestsJson = jsonEncode(processedRequests);
        await prefs.setString(_friendRequestsKey, requestsJson);
      },
      null,
    );
  }

  static Future<List<Map<String, dynamic>>> getCachedFriendRequests() async {
    return await ErrorHandler.handleCacheError(
      'getCachedFriendRequests',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final requestsJson = prefs.getString(_friendRequestsKey);
        final timestamp = prefs.getInt(_cacheTimestampKey) ?? 0;
        
        if (requestsJson == null || timestamp == 0) {
          return <Map<String, dynamic>>[];
        }

        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheValidityDuration) {
          ErrorHandler.logWarning('getCachedFriendRequests', 'Cache expired, clearing');
          await clearCache();
          return <Map<String, dynamic>>[];
        }

        final List<dynamic> requestsList = jsonDecode(requestsJson);
        final requests = requestsList.cast<Map<String, dynamic>>();
        return requests.map((request) => DataTransformationService.transformToFirebaseData(request)).toList();
      },
      <Map<String, dynamic>>[],
    );
  }

  static Future<void> cacheUsers(List<Map<String, dynamic>> users) async {
    await ErrorHandler.handleCacheError(
      'cacheUsers',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final processedUsers = users.map((user) => DataTransformationService.transformFirebaseData(user)).toList();
        final usersJson = jsonEncode(processedUsers);
        await prefs.setString(_usersKey, usersJson);
      },
      null,
    );
  }

  static Future<List<Map<String, dynamic>>> getCachedUsers() async {
    return await ErrorHandler.handleCacheError(
      'getCachedUsers',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final usersJson = prefs.getString(_usersKey);
        final timestamp = prefs.getInt(_cacheTimestampKey) ?? 0;
        
        if (usersJson == null || timestamp == 0) {
          return <Map<String, dynamic>>[];
        }

        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheValidityDuration) {
          ErrorHandler.logWarning('getCachedUsers', 'Cache expired, clearing');
          await clearCache();
          return <Map<String, dynamic>>[];
        }

        final List<dynamic> usersList = jsonDecode(usersJson);
        final users = usersList.cast<Map<String, dynamic>>();
        return users.map((user) => DataTransformationService.transformToFirebaseData(user)).toList();
      },
      <Map<String, dynamic>>[],
    );
  }

  static Future<void> clearCache() async {
    await ErrorHandler.handleCacheError(
      'clearCache',
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_friendsKey);
        await prefs.remove(_friendRequestsKey);
        await prefs.remove(_usersKey);
        await prefs.remove(_cacheTimestampKey);
      },
      null,
    );
  }

  static Future<bool> isCacheValid() async {
    return await ErrorHandler.handleCacheError(
      'isCacheValid',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final timestamp = prefs.getInt(_cacheTimestampKey) ?? 0;
        
        if (timestamp == 0) {
          return false;
        }

        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        return DateTime.now().difference(cacheTime) <= _cacheValidityDuration;
      },
      false,
    );
  }

  static Future<void> forceClearCache() async {
    ErrorHandler.logWarning('forceClearCache', 'Force clearing cache due to corruption');
    await clearCache();
  }

  static Future<Map<String, dynamic>> getCacheStatus() async {
    return await ErrorHandler.handleCacheError(
      'getCacheStatus',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final friendsJson = prefs.getString(_friendsKey);
        final requestsJson = prefs.getString(_friendRequestsKey);
        final usersJson = prefs.getString(_usersKey);
        final timestamp = prefs.getInt(_cacheTimestampKey) ?? 0;
        
        final cacheTime = timestamp > 0 ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
        final isValid = timestamp > 0 && cacheTime != null && DateTime.now().difference(cacheTime) <= _cacheValidityDuration;
        
        return {
          'hasFriends': friendsJson != null,
          'hasRequests': requestsJson != null,
          'hasUsers': usersJson != null,
          'timestamp': timestamp,
          'cacheTime': cacheTime?.toIso8601String(),
          'isValid': isValid,
          'timeSinceCache': cacheTime != null ? DateTime.now().difference(cacheTime).inMinutes : null,
        };
      },
      <String, dynamic>{},
    );
  }
}
