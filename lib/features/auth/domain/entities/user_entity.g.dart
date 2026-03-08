// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserEntity _$UserEntityFromJson(Map<String, dynamic> json) => UserEntity(
  id: json['id'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  middleName: json['middleName'] as String?,
  email: json['email'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  organization: json['organization'] as String?,
  isBlocked: json['isBlocked'] as bool? ?? false,
  requires2FA: json['requires2FA'] as bool? ?? false,
);

Map<String, dynamic> _$UserEntityToJson(UserEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'middleName': instance.middleName,
      'email': instance.email,
      'role': _$UserRoleEnumMap[instance.role]!,
      'organization': instance.organization,
      'isBlocked': instance.isBlocked,
      'requires2FA': instance.requires2FA,
    };

const _$UserRoleEnumMap = {
  UserRole.student: 'student',
  UserRole.teacher: 'teacher',
};
