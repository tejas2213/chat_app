import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String phoneNumber;
  final String? name;

  const UserEntity({
    required this.id,
    required this.phoneNumber,
    this.name,
  });

  @override
  List<Object?> get props => [id, phoneNumber, name];
}