import 'dart:developer' as developer;

class ErrorHandler {
  static const String _tag = 'FriendsCache';
  
  static void logError(String operation, dynamic error, [StackTrace? stackTrace]) {
    developer.log(
      'Error in $operation: $error',
      name: _tag,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  static void logSuccess(String operation, [Map<String, dynamic>? data]) {
    developer.log(
      'Success: $operation',
      name: _tag,
      error: data,
    );
  }
  
  static void logWarning(String operation, String message) {
    developer.log(
      'Warning in $operation: $message',
      name: _tag,
      level: 900, 
    );
  }
  
  static Future<T> handleCacheError<T>(
    String operation,
    Future<T> Function() operationFunction,
    T fallbackValue,
  ) async {
    try {
      final result = await operationFunction();
      logSuccess(operation);
      return result;
    } catch (error, stackTrace) {
      logError(operation, error, stackTrace);
      return fallbackValue;
    }
  }
}
