import 'package:kempa/features/academic/domain/entities/auditory.dart';
import 'package:kempa/features/academic/domain/entities/faculty.dart';
import 'package:kempa/features/academic/domain/entities/group.dart';
import 'package:kempa/features/academic/domain/entities/teacher.dart';

abstract class AcademicRepository {
  Future<List<Faculty>> getFaculties();
  Future<List<Teacher>> getTeachers();
  Future<List<Group>> getGroups(int facultyId);
  Future<List<Auditory>> getAuditories();
}