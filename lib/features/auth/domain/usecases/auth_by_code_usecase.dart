import 'package:kempa/features/auth/domain/entities/user_entity.dart';
import 'package:kempa/features/auth/domain/repositories/auth_repository.dart';

class AuthByCodeUsecase {
  final AuthRepository _repository;

  AuthByCodeUsecase(this._repository);

  Future<UserEntity> execute({
    required String login,
    required String password,
    required String code
  }) {
    return _repository.authByCode(login: login, code: code, password: password);
  }
}