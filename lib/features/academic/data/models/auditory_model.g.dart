// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auditory_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuditoryModel _$AuditoryModelFromJson(Map<String, dynamic> json) =>
    AuditoryModel(
      id: (json['auditoryId'] as num).toInt(),
      name: json['auditoryName'] as String,
      type: json['auditoryType'] as String,
      build: json['auditoryBuild'] as String,
      buildNumber: (json['auditoryBuildNumber'] as num).toInt(),
      scheduleCnt: (json['scheduleCnt'] as num).toInt(),
    );

Map<String, dynamic> _$AuditoryModelToJson(AuditoryModel instance) =>
    <String, dynamic>{
      'auditoryId': instance.id,
      'auditoryName': instance.name,
      'auditoryType': instance.type,
      'auditoryBuild': instance.build,
      'auditoryBuildNumber': instance.buildNumber,
      'scheduleCnt': instance.scheduleCnt,
    };
