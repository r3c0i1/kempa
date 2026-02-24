import 'package:json_annotation/json_annotation.dart';

part 'group_model.g.dart';

@JsonSerializable()
class GroupModel {
  @JsonKey(name: "Id")
  final int id;

  @JsonKey(name: "GroupName")
  final String name;

  final String specName;

  final String learnForm;

  final String? startDate;
  final String? endDate;

  GroupModel({
    required this.id,
    required this.name,
    required this.specName,
    required this.learnForm,
    this.startDate,
    this.endDate
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) => 
      _$GroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$GroupModelToJson(this);
}