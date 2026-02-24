// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupModel _$GroupModelFromJson(Map<String, dynamic> json) => GroupModel(
  id: (json['Id'] as num).toInt(),
  name: json['GroupName'] as String,
  specName: json['specName'] as String,
  learnForm: json['learnForm'] as String,
  startDate: json['startDate'] as String?,
  endDate: json['endDate'] as String?,
);

Map<String, dynamic> _$GroupModelToJson(GroupModel instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'GroupName': instance.name,
      'specName': instance.specName,
      'learnForm': instance.learnForm,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
    };
