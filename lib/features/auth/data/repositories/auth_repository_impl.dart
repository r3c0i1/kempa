import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.remoteDataSource, required this.localDataSource});

  @override
  Future<UserEntity> login({required String login, required String password}) async {
    final response = await remoteDataSource.login(login, password);
    
    if (response.success && response.accessToken != null) {
      await localDataSource.saveTokens(
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
  Future<void> logout() => localDataSource.clear();
  
  @override
  Future<void> updateAuth() async {
    return await remoteDataSource.updateTokens();
  }
}