import 'package:kempa/features/academic/domain/entities/faculty.dart';
import 'package:kempa/features/academic/domain/repositories/academic_repository.dart';

class GetFacultiesUseCase {
  final AcademicRepository _repository;

  GetFacultiesUseCase(this._repository);

  Future<List<Faculty>> execute() {
    return _repository.getFaculties();
  }
}