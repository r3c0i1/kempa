// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faculty_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacultyModel _$FacultyModelFromJson(Map<String, dynamic> json) => FacultyModel(
  id: (json['Id'] as num).toInt(),
  faculty: json['Faculty'] as String,
);

Map<String, dynamic> _$FacultyModelToJson(FacultyModel instance) =>
    <String, dynamic>{'Id': instance.id, 'Faculty': instance.faculty};
