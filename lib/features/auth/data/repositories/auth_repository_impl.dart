import 'package:kempa/core/network/token_manager.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final TokenManager tokenManager;

  AuthRepositoryImpl({required this.remoteDataSource, required this.localDataSource, required this.tokenManager});

  @override
  Future<UserEntity> login({required String login, required String password}) async {
    final response = await remoteDataSource.login(login, password);
    
    if (response.success && response.accessToken != null) {
      await tokenManager.saveTokens(
        access: response.accessToken!,
        refresh: response.refreshToken!,
      );
      if (response.userInfo != null) {
        await localDataSource.cacheUser(response.userInfo!);
      }
      return response.userInfo!.toEntity();
    }
    throw Exception('Неверный логин или пароль');
  }

  @override
  Future<UserEntity?> getAuthenticatedUser() async {
    final user = await localDataSource.getCachedUser();
    return user?.toEntity();
  }

  @override
  Future<void> logout() async {
    await tokenManager.clearTokens();
    await localDataSource.clear();
  }
  
  @override
  Future<void> updateAuth() async {
    return await remoteDataSource.updateTokens();
  }
}