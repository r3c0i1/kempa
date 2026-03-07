import 'dart:async';

import 'package:kempa/core/network/token_manager.dart';
import 'package:kempa/features/auth/domain/exceptions/two_factor_required_exception.dart';

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
    
    if (response.success) {
      if (response.twoFactorAuthEnabled == true && response.accessToken == null) {
        throw TwoFactorRequiredException();
      }
      if (response.accessToken != null && response.userInfo != null) {
        await tokenManager.saveTokens(
          access: response.accessToken!,
          refresh: response.refreshToken!,
        );
        await tokenManager.saveCredentials(login: login, password: password);
        await localDataSource.cacheUser(response.userInfo!);
        return response.userInfo!.toEntity();
      }
      throw Exception('Неизвестная ошибка авторизации');
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
    await tokenManager.clearAll();
    await localDataSource.clear();
  }
  
  @override
  Future<void> updateAuth() async {
    return await remoteDataSource.updateTokens();
  }
  
  @override
  Future<UserEntity> authByCode({required String login, required String password, required String code}) async {
    final response = await remoteDataSource.authByCode(login, code);
    
    if (response.success) {
      if (response.accessToken != null && response.userInfo != null) {
        await tokenManager.saveTokens(
          access: response.accessToken!,
          refresh: response.refreshToken!,
        );
        await tokenManager.saveCredentials(login: login, password: password);
        await localDataSource.cacheUser(response.userInfo!);
        return response.userInfo!.toEntity();
      }
      throw Exception('Неизвестная ошибка авторизации');
    }
    throw Exception('Неверный код');
  }
  
  @override
  Stream<({String login, String password})> get onTwoFactorRequired => tokenManager.onTwoFactorRequired;
}