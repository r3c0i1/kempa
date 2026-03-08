import 'package:json_annotation/json_annotation.dart';
import 'package:kempa/features/academic/domain/entities/teacher.dart';

part 'teacher_model.g.dart';

@JsonSerializable()
class TeacherModel {
  @JsonKey(name: "prepId")
  final int id;

  @JsonKey(name: "fio")
  final String fullName;

  TeacherModel({
    required this.id,
    required this.fullName
  });

  Teacher toEntity() {
    return Teacher(
      id: id, 
      fullName: fullName
    );
  }

  factory TeacherModel.fromJson(Map<String, dynamic> json) => 
    _$TeacherModelFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherModelToJson(this);
}