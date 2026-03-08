import 'package:json_annotation/json_annotation.dart';
import 'package:kempa/features/academic/domain/entities/auditory.dart';

part 'auditory_model.g.dart';

@JsonSerializable()
class AuditoryModel {
  @JsonKey(name: "auditoryId")
  final int id;

  @JsonKey(name: "auditoryName")
  final String name;

  @JsonKey(name: "auditoryType")
  final String type;

  @JsonKey(name: "auditoryBuild")
  final String build;

  @JsonKey(name: "auditoryBuildNumber")
  final int buildNumber;

  @JsonKey(name: "scheduleCnt")
  final int scheduleCnt;

  AuditoryModel({
    required this.id,
    required this.name, 
    required this.type,
    required this.build,
    required this.buildNumber,
    required this.scheduleCnt
  });

  Auditory toEntity() {
    return Auditory(
      id: id, 
      name: name, 
      type: type, 
      build: build, 
      buildNumber: buildNumber
    );
  }

  factory AuditoryModel.fromJson(Map<String, dynamic> json) => 
    _$AuditoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuditoryModelToJson(this);
}