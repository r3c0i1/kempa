import 'package:equatable/equatable.dart';

class DayInfo extends Equatable {
  final int weekNum;
  final String weekType;
  final String currentDate;
  final String currentDay;

  const DayInfo({
    required this.weekNum,
    required this.weekType,
    required this.currentDate,
    required this.currentDay,
  });

  bool get isEven => weekType == 'четная';

  @override
  List<Object?> get props => [weekNum, weekType, currentDate, currentDay];
}