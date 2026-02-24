import 'package:flutter/material.dart';
import '../../domain/entities/calendar_day.dart';
import '../../domain/entities/day_info.dart';

class WeekIndicator extends StatelessWidget {
  final CalendarDay selectedDay;
  final DayInfo dayInfo;
  final VoidCallback? onTodayPressed;
  final bool showTodayButton;

  const WeekIndicator({
    super.key,
    required this.selectedDay,
    required this.dayInfo,
    this.onTodayPressed,
    this.showTodayButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Определяем тип недели для выбранного дня
    final isEven = selectedDay.weekId % 2 == 0;
    final weekType = isEven ? 'чётная' : 'нечётная';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Неделя и тип
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
                SizedBox(width: 6),
                Text(
                  'Неделя ${selectedDay.weekId}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    weekType,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Spacer(),

          // Кнопка "Сегодня"
          if (showTodayButton && onTodayPressed != null)
            TextButton.icon(
              onPressed: onTodayPressed,
              icon: Icon(Icons.today, size: 18),
              label: Text('Сегодня'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
    );
  }
}