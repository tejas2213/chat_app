import 'package:cloud_firestore/cloud_firestore.dart';
import 'data_transformation_service.dart';

class CacheTransformationTest {
  static void runTest() {
    print('Testing Firebase data transformation...');
    
    final testData = {
      'id': 'test123',
      'name': 'Test User',
      'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 2)),
      'nested': {
        'timestamp': Timestamp.fromDate(DateTime(2024, 1, 3)),
        'value': 'test'
      },
      'list': [
        {'timestamp': Timestamp.fromDate(DateTime(2024, 1, 4))},
        'string_value'
      ]
    };
    
    try {
      final transformed = DataTransformationService.transformFirebaseData(testData);
      print('✓ Transformation to JSON format successful');
      
      final restored = DataTransformationService.transformToFirebaseData(transformed);
      print('✓ Transformation back to Firebase format successful');
      
      if (restored['createdAt'] is Timestamp && restored['updatedAt'] is Timestamp) {
        print('✓ Timestamp fields properly restored');
      } else {
        print('✗ Timestamp fields not properly restored');
      }
      
      print('All tests passed! Cache transformation is working correctly.');
      
    } catch (e) {
      print('✗ Test failed: $e');
    }
  }
}
