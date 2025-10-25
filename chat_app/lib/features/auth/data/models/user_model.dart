class UserModel {
  final String id;
  final String phoneNumber;
  final String? name;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.phoneNumber,
    this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      phoneNumber: map['phoneNumber'],
      name: map['name'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
}