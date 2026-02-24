import 'package:equatable/equatable.dart';
import '../../domain/entities/day_info.dart';

abstract class ScheduleState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class DayInfoLoaded extends ScheduleState {
  final DayInfo dayInfo;

  DayInfoLoaded(this.dayInfo);

  @override
  List<Object?> get props => [dayInfo];
}

class ScheduleError extends ScheduleState {
  final String message;

  ScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}