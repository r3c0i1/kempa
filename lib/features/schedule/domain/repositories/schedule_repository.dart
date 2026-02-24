import '../entities/day_info.dart';

abstract class ScheduleRepository {
  Future<DayInfo> getDayInfo();
}