import 'package:kempa/features/auth/domain/repositories/auth_repository.dart';

class AuthUpdateUseCase {
  final AuthRepository repository;

  AuthUpdateUseCase(this.repository);

  Future<void> execute() async {
    return await repository.updateAuth();
  }
}