import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kempa/features/auth/domain/entities/user_entity.dart';
import 'package:kempa/features/auth/domain/repositories/auth_repository.dart';
import 'package:kempa/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:kempa/features/auth/domain/usecases/login_usecase.dart';
import 'package:kempa/features/auth/domain/usecases/logout_usecase.dart';
import 'package:kempa/features/auth/domain/usecases/auth_by_code_usecase.dart';
import 'package:kempa/features/auth/domain/exceptions/two_factor_required_exception.dart';
import 'package:kempa/features/auth/domain/exceptions/auth_invalid_credentials_exception.dart';
import 'package:kempa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kempa/features/auth/presentation/bloc/auth_event.dart';
import 'package:kempa/features/auth/presentation/bloc/auth_state.dart';

// Моки
class MockCheckAuthUsecase extends Mock implements CheckAuthUsecase {}
class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockLogoutUsecase extends Mock implements LogoutUsecase {}
class MockAuthByCodeUsecase extends Mock implements AuthByCodeUsecase {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthBloc authBloc;
  late MockCheckAuthUsecase mockCheckAuthUsecase;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockAuthByCodeUsecase mockAuthByCodeUsecase;
  late MockAuthRepository mockAuthRepository;

  final testUser = UserEntity(
    id: '1',
    firstName: 'Иван',
    lastName: 'Иванов',
    email: 'test@test.ru',
    role: UserRole.student,
  );

  setUp(() {
    mockCheckAuthUsecase = MockCheckAuthUsecase();
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockAuthByCodeUsecase = MockAuthByCodeUsecase();
    mockAuthRepository = MockAuthRepository();

    when(() => mockAuthRepository.onTwoFactorRequired)
        .thenAnswer((_) => const Stream.empty());

    authBloc = AuthBloc(
      checkAuthUsecase: mockCheckAuthUsecase,
      loginUseCase: mockLoginUseCase,
      logoutUsecase: mockLogoutUsecase,
      authByCodeUseCase: mockAuthByCodeUsecase,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthCheckEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthCheckingState, AuthentificatedState] when user is cached',
      build: () {
        when(() => mockCheckAuthUsecase.execute())
            .thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckEvent()),
      expect: () => [
        AuthCheckingState(),
        AuthentificatedState(testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthCheckingState, AuthLoginState] when user is not cached',
      build: () {
        when(() => mockCheckAuthUsecase.execute())
            .thenAnswer((_) async => null);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckEvent()),
      expect: () => [
        AuthCheckingState(),
        AuthLoginState(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthCheckingState, AuthLoginState] when check throws exception',
      build: () {
        when(() => mockCheckAuthUsecase.execute())
            .thenThrow(Exception('Network error'));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckEvent()),
      expect: () => [
        AuthCheckingState(),
        AuthLoginState(),
      ],
    );
  });

  group('AuthLoginEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoginState(loading), AuthentificatedState] when login succeeds',
      build: () {
        when(() => mockLoginUseCase.execute(any(), any()))
            .thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLoginEvent(
        login: 'testuser',
        password: 'password123',
      )),
      expect: () => [
        AuthLoginState(isLoading: true),
        AuthentificatedState(testUser),
      ],
      verify: (_) {
        verify(() => mockLoginUseCase.execute('testuser', 'password123')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoginState(loading), AuthTwoFactorState] when 2FA required',
      build: () {
        when(() => mockLoginUseCase.execute(any(), any()))
            .thenThrow(TwoFactorRequiredException());
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLoginEvent(
        login: 'testuser',
        password: 'password123',
      )),
      expect: () => [
        AuthLoginState(isLoading: true),
        AuthTwoFactorState(
          login: 'testuser',
          password: 'password123',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoginState(loading), AuthLoginState(error)] when credentials invalid',
      build: () {
        when(() => mockLoginUseCase.execute(any(), any()))
            .thenThrow(AuthInvalidCredentialsException());
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLoginEvent(
        login: 'testuser',
        password: 'wrongpassword',
      )),
      expect: () => [
        AuthLoginState(isLoading: true),
        AuthLoginState(isLoading: false, errorMessage: 'Неверный логин или пароль'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoginState(loading), AuthLoginState(error)] when network error',
      build: () {
        when(() => mockLoginUseCase.execute(any(), any()))
            .thenThrow(Exception('Network error'));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLoginEvent(
        login: 'testuser',
        password: 'password123',
      )),
      expect: () => [
        AuthLoginState(isLoading: true),
        AuthLoginState(isLoading: false, errorMessage: 'Ошибка подключения'),
      ],
    );
  });

  group('AuthTwoFactorCodeSubmittedEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthTwoFactorState(loading), AuthentificatedState] when code is valid',
      build: () {
        when(() => mockAuthByCodeUsecase.execute(
          login: any(named: 'login'),
          password: any(named: 'password'),
          code: any(named: 'code'),
        )).thenAnswer((_) async => testUser);
        return authBloc;
      },
      seed: () => AuthTwoFactorState(
        login: 'testuser',
        password: 'password123',
      ),
      act: (bloc) => bloc.add(AuthTwoFactorCodeSubmittedEvent('123456')),
      expect: () => [
        AuthTwoFactorState(
          login: 'testuser',
          password: 'password123',
          isLoading: true,
        ),
        AuthentificatedState(testUser),
      ],
      verify: (_) {
        verify(() => mockAuthByCodeUsecase.execute(
          login: 'testuser',
          password: 'password123',
          code: '123456',
        )).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthTwoFactorState(loading), AuthTwoFactorState(error)] when code is invalid',
      build: () {
        when(() => mockAuthByCodeUsecase.execute(
          login: any(named: 'login'),
          password: any(named: 'password'),
          code: any(named: 'code'),
        )).thenThrow(Exception('Invalid code'));
        return authBloc;
      },
      seed: () => AuthTwoFactorState(
        login: 'testuser',
        password: 'password123',
      ),
      act: (bloc) => bloc.add(AuthTwoFactorCodeSubmittedEvent('000000')),
      expect: () => [
        AuthTwoFactorState(
          login: 'testuser',
          password: 'password123',
          isLoading: true,
        ),
        AuthTwoFactorState(
          login: 'testuser',
          password: 'password123',
          isLoading: false,
          error: 'Неверный код',
        ),
      ],
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [UnauthenticatedState] when logout requested',
      build: () {
        when(() => mockLogoutUsecase.execute())
            .thenAnswer((_) async {});
        return authBloc;
      },
      seed: () => AuthentificatedState(testUser),
      act: (bloc) => bloc.add(AuthLogoutEvent()),
      expect: () => [
        UnauthenticatedState(),
      ],
      verify: (_) {
        verify(() => mockLogoutUsecase.execute()).called(1);
      },
    );
  });

  group('TwoFactorResendRequested', () {
    blocTest<AuthBloc, AuthState>(
      'does not emit new state when resend succeeds (2FA expected)',
      build: () {
        when(() => mockLoginUseCase.execute(any(), any()))
            .thenThrow(TwoFactorRequiredException());
        return authBloc;
      },
      seed: () => AuthTwoFactorState(
        login: 'testuser',
        password: 'password123',
      ),
      act: (bloc) => bloc.add(AuthTwoFactorResendEvent()),
      expect: () => [],  // Состояние не меняется
      verify: (_) {
        verify(() => mockLoginUseCase.execute('testuser', 'password123')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthTwoFactorState(error)] when resend fails',
      build: () {
        when(() => mockLoginUseCase.execute(any(), any()))
            .thenThrow(Exception('Network error'));
        return authBloc;
      },
      seed: () => AuthTwoFactorState(
        login: 'testuser',
        password: 'password123',
      ),
      act: (bloc) => bloc.add(AuthTwoFactorResendEvent()),
      expect: () => [
        AuthTwoFactorState(
          login: 'testuser',
          password: 'password123',
          error: 'Не удалось отправить код',
        ),
      ],
    );
  });

  group('Background TwoFactor (Stream)', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthTwoFactorState(isBackground: true)] when stream emits',
      build: () {
        final controller = StreamController<({String login, String password})>();
        
        when(() => mockAuthRepository.onTwoFactorRequired)
            .thenAnswer((_) => controller.stream);
        
        final bloc = AuthBloc(
          checkAuthUsecase: mockCheckAuthUsecase,
          loginUseCase: mockLoginUseCase,
          logoutUsecase: mockLogoutUsecase,
          authByCodeUseCase: mockAuthByCodeUsecase,
          authRepository: mockAuthRepository,
        );
        
        // Эмитим событие в стрим после создания блока
        Future.microtask(() {
          controller.add((login: 'testuser', password: 'password123'));
        });
        
        return bloc;
      },
      seed: () => AuthentificatedState(testUser),  // Пользователь был авторизован
      wait: const Duration(milliseconds: 100),  // Ждём пока стрим сработает
      expect: () => [
        AuthTwoFactorState(
          login: 'testuser',
          password: 'password123',
          isBackground: true,
        ),
      ],
    );
  });
}