import 'package:json_annotation/json_annotation.dart';
import 'package:kempa/features/auth/domain/entities/user_entity.dart';

part 'auth_response_model.g.dart'; 

@JsonSerializable()
class SettingsModel {
  final bool? hideTeacherSchedule;

  SettingsModel({this.hideTeacherSchedule});

  factory SettingsModel.fromJson(Map<String, dynamic> json) => 
      _$SettingsModelFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsModelToJson(this);
}

@JsonSerializable()
class UserInfoModel {
  final int? id;
  final String? login;
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String? email;
  final String? userType;
  final String? org;
  final int? blocked;
  final bool? twoFactorAuth;

  final SettingsModel? settings;

  UserInfoModel({
    this.id,
    this.login,
    this.firstName,
    this.lastName,
    this.middleName,
    this.email,
    this.userType,
    this.org,
    this.blocked,
    this.twoFactorAuth,
    this.settings
  });

  Map<String, dynamic> toJson() => _$UserInfoModelToJson(this);

  factory UserInfoModel.fromJson(Map<String, dynamic> json) => 
      _$UserInfoModelFromJson(json);

  UserEntity toEntity() {
    return UserEntity(
      id: id?.toString() ?? '0',
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      middleName: middleName,
      email: email ?? '',
      role: userType?.toLowerCase().contains('сотрудник') == true ? UserRole.teacher : UserRole.student,
      isBlocked: blocked == 1,
      requires2FA: twoFactorAuth ?? false,
    );
  }
}

@JsonSerializable()
class AuthResponseModel {
  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final UserInfoModel? userInfo;
  final bool? twoFactorAuthEnabled;

  AuthResponseModel({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.userInfo,
    this.twoFactorAuthEnabled
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => 
    _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}
