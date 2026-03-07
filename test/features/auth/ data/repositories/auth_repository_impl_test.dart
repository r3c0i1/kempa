// test/features/auth/data/repositories/auth_repository_impl_test.dart

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kempa/core/network/token_manager.dart';
import 'package:kempa/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:kempa/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:kempa/features/auth/data/models/auth_response_model.dart';
import 'package:kempa/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kempa/features/auth/domain/entities/user_entity.dart';
import 'package:kempa/features/auth/domain/exceptions/two_factor_required_exception.dart';

// Моки
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}
class MockTokenManager extends Mock implements TokenManager {}

// Fake для UserInfoModel
class FakeUserInfoModel extends Fake implements UserInfoModel {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockTokenManager mockTokenManager;

  final testUserInfoModel = UserInfoModel(
    id: 1,
    login: 'testuser',
    firstName: 'Иван',
    lastName: 'Иванов',
    email: 'test@test.ru',
    userType: 'Студент',
  );

  final testAuthResponse = AuthResponseModel(
    success: true,
    accessToken: 'access_token_123',
    refreshToken: 'refresh_token_456',
    userInfo: testUserInfoModel,
  );

  final testTwoFactorResponse = AuthResponseModel(
    success: true,
    twoFactorAuthEnabled: true,
    accessToken: null,
    refreshToken: null,
    userInfo: null,
  );

  // Регистрируем fallback значения
  setUpAll(() {
    registerFallbackValue(FakeUserInfoModel());
  });

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockTokenManager = MockTokenManager();

    // Дефолтные моки для всех методов
    when(() => mockTokenManager.onTwoFactorRequired)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockTokenManager.saveTokens(access: any(named: 'access'), refresh: any(named: 'refresh')))
        .thenAnswer((_) async {});
    when(() => mockTokenManager.saveCredentials(login: any(named: 'login'), password: any(named: 'password')))
        .thenAnswer((_) async {});
    when(() => mockTokenManager.clearAll())
        .thenAnswer((_) async {});
    when(() => mockLocalDataSource.cacheUser(any()))
        .thenAnswer((_) async {});
    when(() => mockLocalDataSource.clear())
        .thenAnswer((_) async {});
    when(() => mockLocalDataSource.getCachedUser())
        .thenAnswer((_) async => null);
    when(() => mockRemoteDataSource.updateTokens())
        .thenAnswer((_) async {});

    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      tokenManager: mockTokenManager,
    );
  });

  group('login', () {
    test('returns UserEntity when login succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.login(any(), any()))
          .thenAnswer((_) async => testAuthResponse);

      // Act
      final result = await repository.login(login: 'testuser', password: 'password123');

      // Assert
      expect(result, isA<UserEntity>());
      expect(result.firstName, 'Иван');
      expect(result.email, 'test@test.ru');

      verify(() => mockRemoteDataSource.login('testuser', 'password123')).called(1);
      verify(() => mockTokenManager.saveTokens(access: 'access_token_123', refresh: 'refresh_token_456')).called(1);
      verify(() => mockTokenManager.saveCredentials(login: 'testuser', password: 'password123')).called(1);
      verify(() => mockLocalDataSource.cacheUser(any())).called(1);
    });

    test('throws TwoFactorRequiredException when 2FA enabled', () async {
      // Arrange
      when(() => mockRemoteDataSource.login(any(), any()))
          .thenAnswer((_) async => testTwoFactorResponse);

      // Act & Assert
      expect(
        () => repository.login(login: 'testuser', password: 'password123'),
        throwsA(isA<TwoFactorRequiredException>()),
      );
    });

    test('throws Exception when response is not successful', () async {
      // Arrange
      final failedResponse = AuthResponseModel(success: false);
      when(() => mockRemoteDataSource.login(any(), any()))
          .thenAnswer((_) async => failedResponse);

      // Act & Assert
      expect(
        () => repository.login(login: 'testuser', password: 'wrongpassword'),
        throwsA(isA<Exception>()),
      );
    });

    test('rethrows exception from remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.login(any(), any()))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => repository.login(login: 'testuser', password: 'password123'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('authByCode', () {
    test('returns UserEntity when code is valid', () async {
      // Arrange
      when(() => mockRemoteDataSource.authByCode(any(), any()))
          .thenAnswer((_) async => testAuthResponse);

      // Act
      final result = await repository.authByCode(
        login: 'testuser',
        password: 'password123',
        code: '123456',
      );

      // Assert
      expect(result, isA<UserEntity>());
      expect(result.firstName, 'Иван');

      verify(() => mockRemoteDataSource.authByCode('testuser', '123456')).called(1);
      verify(() => mockTokenManager.saveTokens(access: 'access_token_123', refresh: 'refresh_token_456')).called(1);
      verify(() => mockTokenManager.saveCredentials(login: 'testuser', password: 'password123')).called(1);
      verify(() => mockLocalDataSource.cacheUser(any())).called(1);
    });

    test('throws Exception when code is invalid', () async {
      // Arrange
      final failedResponse = AuthResponseModel(success: false);
      when(() => mockRemoteDataSource.authByCode(any(), any()))
          .thenAnswer((_) async => failedResponse);

      // Act & Assert
      expect(
        () => repository.authByCode(login: 'testuser', password: 'password123', code: '000000'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getAuthenticatedUser', () {
    test('returns UserEntity when user is cached', () async {
      // Arrange
      when(() => mockLocalDataSource.getCachedUser())
          .thenAnswer((_) async => testUserInfoModel);

      // Act
      final result = await repository.getAuthenticatedUser();

      // Assert
      expect(result, isA<UserEntity>());
      expect(result?.firstName, 'Иван');
      verify(() => mockLocalDataSource.getCachedUser()).called(1);
    });

    test('returns null when no user cached', () async {
      // Arrange
      when(() => mockLocalDataSource.getCachedUser())
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.getAuthenticatedUser();

      // Assert
      expect(result, isNull);
    });
  });

  group('logout', () {
    test('clears tokens and cached user', () async {
      // Act
      await repository.logout();

      // Assert
      verify(() => mockTokenManager.clearAll()).called(1);
      verify(() => mockLocalDataSource.clear()).called(1);
    });
  });

  group('updateAuth', () {
    test('calls remote data source updateTokens', () async {
      // Act
      await repository.updateAuth();

      // Assert
      verify(() => mockRemoteDataSource.updateTokens()).called(1);
    });
  });

  group('onTwoFactorRequired', () {
    test('returns stream from TokenManager', () {
      // Assert
      expect(repository.onTwoFactorRequired, isA<Stream>());
      verify(() => mockTokenManager.onTwoFactorRequired).called(1);
    });
  });
}