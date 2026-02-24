import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_day_info.dart';
import 'schedule_event.dart';
import 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final GetDayInfo getDayInfo;

  ScheduleBloc({required this.getDayInfo}) : super(ScheduleInitial()) {
    on<DayInfoRequested>(_onDayInfoRequested);
  }

  Future<void> _onDayInfoRequested(
    DayInfoRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());

    try {
      final dayInfo = await getDayInfo.execute();
      emit(DayInfoLoaded(dayInfo));
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }
}