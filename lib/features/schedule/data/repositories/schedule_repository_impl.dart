import 'package:kempa/features/schedule/data/datasources/schedule_remote_datasource.dart';
import 'package:kempa/features/schedule/domain/entities/day_info.dart';
import 'package:kempa/features/schedule/domain/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {

  final ScheduleRemoteDatasource remote;

  ScheduleRepositoryImpl(this.remote);

  @override
  Future<DayInfo> getDayInfo() async {
    return (await remote.getDayInfo()).toEntity();
  }
  
}