import 'package:equatable/equatable.dart';

class CalendarDay extends Equatable {
  final int weekId;
  final int dayNum;          // 1-6 (Пн-Сб)
  final String dayName;      // "Пн", "Вт"...
  final String dayNameFull;  // "Понедельник"
  final DateTime date;
  final bool isToday;

  const CalendarDay({
    required this.weekId,
    required this.dayNum,
    required this.dayName,
    required this.dayNameFull,
    required this.date,
    required this.isToday,
  });

  String get dateFormatted => '${date.day}';
  
  String get monthShort {
    const months = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
    ];
    return months[date.month - 1];
  }

  // Показываем месяц если это 1-е число или первый день в списке
  bool get showMonth => date.day == 1;

  @override
  List<Object?> get props => [weekId, dayNum, date];
}