import 'package:kempa/features/schedule/domain/entities/day_info.dart';
import 'package:kempa/features/schedule/domain/repositories/schedule_repository.dart';

class GetDayInfo {
  final ScheduleRepository repository;

  GetDayInfo(this.repository);

  Future<DayInfo> execute() async {
    return repository.getDayInfo();
  }
}