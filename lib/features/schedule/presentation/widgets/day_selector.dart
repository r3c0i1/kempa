import 'package:flutter/material.dart';
import '../../domain/entities/calendar_day.dart';

class DaySelector extends StatefulWidget {
  final List<CalendarDay> days;
  final int selectedIndex;
  final ValueChanged<int> onDaySelected;

  const DaySelector({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  @override
  State<DaySelector> createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  late ScrollController _scrollController;
  
  static const double _itemWidth = 52.0;
  static const double _itemSpacing = 4.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: _calculateOffset(widget.selectedIndex),
    );
  }

  @override
  void didUpdateWidget(DaySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Скроллим к выбранному дню если изменился снаружи
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _scrollToIndex(widget.selectedIndex);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double _calculateOffset(int index) {
    final screenWidth = WidgetsBinding
        .instance.platformDispatcher.views.first.physicalSize.width /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    
    // Центрируем выбранный элемент
    final itemOffset = index * (_itemWidth + _itemSpacing);
    final centerOffset = (screenWidth - _itemWidth) / 2;
    return itemOffset - centerOffset + _itemSpacing;
  }

  void _scrollToIndex(int index) {
    final offset = _calculateOffset(index);
    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.days.length,
        itemBuilder: (context, index) {
          final day = widget.days[index];
          final isSelected = index == widget.selectedIndex;
          final showMonthLabel = index == 0 || day.showMonth;

          return Padding(
            padding: EdgeInsets.only(right: _itemSpacing),
            child: Column(
              children: [
                // Месяц (показываем над первым днём месяца)
                SizedBox(
                  height: 16,
                  child: showMonthLabel
                      ? Text(
                          day.monthShort,
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        )
                      : null,
                ),
                
                // День
                GestureDetector(
                  onTap: () {
                    widget.onDaySelected(index);
                    _scrollToIndex(index);
                  },
                  child: _DayChip(
                    day: day,
                    isSelected: isSelected,
                    width: _itemWidth,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final CalendarDay day;
  final bool isSelected;
  final double width;

  const _DayChip({
    required this.day,
    required this.isSelected,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: width,
      height: 56,
      decoration: BoxDecoration(
        color: isSelected 
            ? scheme.primary 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: day.isToday && !isSelected
            ? Border.all(color: scheme.primary, width: 1.5)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // День недели
          Text(
            day.dayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? scheme.onPrimary
                  : scheme.onSurfaceVariant,
            ),
          ),
          
          SizedBox(height: 2),
          
          // Число
          Text(
            day.dateFormatted,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? scheme.onPrimary
                  : scheme.onSurface,
            ),
          ),
          
          // Точка "сегодня" (если выбран)
          if (day.isToday && isSelected)
            Container(
              margin: EdgeInsets.only(top: 2),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onPrimary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}