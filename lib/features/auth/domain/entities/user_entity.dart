import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_entity.g.dart';

enum UserRole { student, teacher}

@JsonSerializable()
class UserEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String email;
  final UserRole role;
  final String? organization;
  final bool isBlocked;
  final bool requires2FA;

  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.email,
    required this.role,
    this.organization,
    this.isBlocked = false,
    this.requires2FA = false
  });

  @override
  List<Object?> get props => [id, email, role];

  factory UserEntity.fromJson(Map<String, dynamic> json) => 
    _$UserEntityFromJson(json);

  Map<String, dynamic> toJson() => _$UserEntityToJson(this);
}
