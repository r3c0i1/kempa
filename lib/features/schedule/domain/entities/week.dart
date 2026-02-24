import 'package:equatable/equatable.dart';

class Week extends Equatable {
  final int id;
  final int num;
  final String? startDate;      // "17.02.2025"
  final String? endDate;        // "22.02.2025"
  final String? startDateShort; // "17 фев"

  const Week({
    required this.id,
    required this.num,
    this.startDate,
    this.endDate,
    this.startDateShort,
  });

  @override
  List<Object?> get props => [id, num, startDate];
}