import 'package:kempa/features/auth/domain/entities/user_entity.dart';
import 'package:kempa/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> execute(String login, String password) async {
    return await repository.login(login: login, password: password);
  }
}
