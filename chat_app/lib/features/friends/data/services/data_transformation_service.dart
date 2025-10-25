import 'package:cloud_firestore/cloud_firestore.dart';

class DataTransformationService {
  static Map<String, dynamic> transformFirebaseData(Map<String, dynamic> data) {
    final transformed = <String, dynamic>{};
    
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value is Timestamp) {
        transformed[key] = value.millisecondsSinceEpoch;
      } else if (value is DateTime) {
        transformed[key] = value.millisecondsSinceEpoch;
      } else if (value is Map<String, dynamic>) {
        transformed[key] = transformFirebaseData(value);
      } else if (value is List) {
        transformed[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return transformFirebaseData(item);
          } else if (item is Timestamp) {
            return item.millisecondsSinceEpoch;
          } else if (item is DateTime) {
            return item.millisecondsSinceEpoch;
          }
          return item;
        }).toList();
      } else {
        transformed[key] = value;
      }
    }
    
    return transformed;
  }
  
  static Map<String, dynamic> transformToFirebaseData(Map<String, dynamic> data) {
    final transformed = <String, dynamic>{};
    
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (key == 'createdAt' || key == 'updatedAt' || key == 'lastLoginAt' || key == 'acceptedAt' || key == 'rejectedAt') {
        if (value is int) {
          transformed[key] = Timestamp.fromMillisecondsSinceEpoch(value);
        } else {
          transformed[key] = value;
        }
      } else if (value is Map<String, dynamic>) {
        transformed[key] = transformToFirebaseData(value);
      } else if (value is List) {
        transformed[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return transformToFirebaseData(item);
          }
          return item;
        }).toList();
      } else {
        transformed[key] = value;
      }
    }
    
    return transformed;
  }
}
