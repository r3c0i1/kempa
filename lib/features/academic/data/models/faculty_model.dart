import 'package:json_annotation/json_annotation.dart';
import 'package:kempa/features/academic/domain/entities/faculty.dart';

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

  Faculty toEntity(){
    return Faculty(id: id, name: faculty);
  }

  factory FacultyModel.fromJson(Map<String, dynamic> json) => 
      _$FacultyModelFromJson(json);

  Map<String, dynamic> toJson() => _$FacultyModelToJson(this);
}