import 'package:kempa/features/academic/data/datasources/academic_remote_datasource.dart';
import 'package:kempa/features/academic/domain/entities/auditory.dart';
import 'package:kempa/features/academic/domain/entities/faculty.dart';
import 'package:kempa/features/academic/domain/entities/group.dart';
import 'package:kempa/features/academic/domain/entities/teacher.dart';
import 'package:kempa/features/academic/domain/repositories/academic_repository.dart';

class AcademicRepositoryImpl implements AcademicRepository {

  final AcademicRemoteDatasource _remote;

  AcademicRepositoryImpl(this._remote);

  @override
  Future<List<Faculty>> getFaculties() async {
    final models = await _remote.getFaculties();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Auditory>> getAuditories() async {
    final models = await _remote.getAuditories();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Group>> getGroups(int facultyId) async {
    final models = await _remote.getGroups(facultyId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Teacher>> getTeachers() async {
    final models = await _remote.getTeachers();
    return models.map((model) => model.toEntity()).toList();
  }
}