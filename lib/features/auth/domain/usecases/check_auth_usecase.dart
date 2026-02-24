import 'package:kempa/features/auth/domain/entities/user_entity.dart';
import 'package:kempa/features/auth/domain/repositories/auth_repository.dart';

class CheckAuthUsecase {
  final AuthRepository repository;

  CheckAuthUsecase(this.repository);

  Future<UserEntity?> execute() async {
    return await repository.getAuthenticatedUser();
  }
}