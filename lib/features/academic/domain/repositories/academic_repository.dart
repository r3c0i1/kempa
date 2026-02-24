import 'package:kempa/features/academic/domain/entities/faculty.dart';

abstract class AcademicRepository {
  Future<List<Faculty>> getFaculties();
}