import 'package:kempa/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({
    required String login,
    required String password
  });

  Future<UserEntity?> getAuthenticatedUser();

  Future<void> logout();
  Future<void> updateAuth();
}