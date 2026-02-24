// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayInfoModel _$DayInfoModelFromJson(Map<String, dynamic> json) => DayInfoModel(
  weekNum: (json['weekNum'] as num).toInt(),
  weekType: json['weekType'] as String,
  currentDate: json['currentDate'] as String,
  currentDay: json['currentDay'] as String,
);

Map<String, dynamic> _$DayInfoModelToJson(DayInfoModel instance) =>
    <String, dynamic>{
      'weekNum': instance.weekNum,
      'weekType': instance.weekType,
      'currentDate': instance.currentDate,
      'currentDay': instance.currentDay,
    };
