import 'package:json_annotation/json_annotation.dart';

part 'faculty_model.g.dart';

@JsonSerializable()
class FacultyModel {
  @JsonKey(name: "Id")
  final int id;

  @JsonKey(name: "Faculty")
  final String faculty;

  FacultyModel({
    required this.id,
    required this.faculty
  });

  factory FacultyModel.fromJson(Map<String, dynamic> json) => 
      _$FacultyModelFromJson(json);

  Map<String, dynamic> toJson() => _$FacultyModelToJson(this);
}