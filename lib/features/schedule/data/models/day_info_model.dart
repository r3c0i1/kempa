import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/day_info.dart';

part 'day_info_model.g.dart';

@JsonSerializable()
class DayInfoModel {
  final int weekNum;
  final String weekType;
  final String currentDate;
  final String currentDay;

  DayInfoModel({
    required this.weekNum,
    required this.weekType,
    required this.currentDate,
    required this.currentDay,
  });

  factory DayInfoModel.fromJson(Map<String, dynamic> json) =>
      _$DayInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$DayInfoModelToJson(this);

  DayInfo toEntity() {
    return DayInfo(
      weekNum: weekNum,
      weekType: weekType,
      currentDate: currentDate,
      currentDay: currentDay,
    );
  }
}
