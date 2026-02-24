import '../entities/calendar_day.dart';
import '../entities/day_info.dart';
import '../entities/week.dart';

class CalendarGenerator {
  static const _dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];
  static const _dayNamesFull = [
    'Понедельник', 'Вторник', 'Среда', 
    'Четверг', 'Пятница', 'Суббота'
  ];

  static List<CalendarDay> generate({
    required List<Week> weeks,
    required DayInfo currentDayInfo,
  }) {
    final days = <CalendarDay>[];
    final today = _parseDate(currentDayInfo.currentDate);

    for (final week in weeks) {
      if (week.startDate == null) continue;

      final weekStart = _parseDate(week.startDate!);

      for (int dayNum = 1; dayNum <= 6; dayNum++) {
        final date = weekStart.add(Duration(days: dayNum - 1));

        days.add(CalendarDay(
          weekId: week.id,
          dayNum: dayNum,
          dayName: _dayNames[dayNum - 1],
          dayNameFull: _dayNamesFull[dayNum - 1],
          date: date,
          isToday: _isSameDay(date, today),
        ));
      }
    }

    return days;
  }

  static int findTodayIndex(List<CalendarDay> days) {
    final index = days.indexWhere((d) => d.isToday);
    return index >= 0 ? index : 0;
  }

  static DateTime _parseDate(String date) {
    // Формат: "21.02.2026"
    final parts = date.split('.');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}