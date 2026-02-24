import 'package:kempa/features/academic/data/datasources/academic_remote_datasource.dart';
import 'package:kempa/features/academic/domain/entities/faculty.dart';
import 'package:kempa/features/academic/domain/repositories/academic_repository.dart';

class AcademicRepositoryImpl implements AcademicRepository {

  final AcademicRemoteDatasource _remote;

  AcademicRepositoryImpl(this._remote);

  @override
  Future<List<Faculty>> getFaculties() async {
    final models = await _remote.getFaculties();
    return models.map((model) => Faculty(id: model.id, name: model.faculty)).toList();
  }
}