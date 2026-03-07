import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kempa/features/auth/domain/exceptions/auth_invalid_credentials_exception.dart';
import 'package:kempa/features/auth/domain/exceptions/two_factor_required_exception.dart';
import 'package:kempa/features/auth/domain/repositories/auth_repository.dart';
import 'package:kempa/features/auth/domain/usecases/auth_by_code_usecase.dart';
import 'package:kempa/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:kempa/features/auth/domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/usecases/login_usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final CheckAuthUsecase checkAuthUsecase;
  final LogoutUsecase logoutUsecase;
  final AuthByCodeUsecase authByCodeUseCase;

  final AuthRepository authRepository;
  StreamSubscription? _twoFactorSub;

  AuthBloc({
    required this.authRepository,
    required this.loginUseCase,
    required this.checkAuthUsecase,
    required this.logoutUsecase,
    required this.authByCodeUseCase
  }) : super(AuthInitialState()) {
    _twoFactorSub = authRepository.onTwoFactorRequired.listen((data) {
      add(AuthTwoFactorRequiredEvent(
        login: data.login, 
        password: data.password,
        isBackground: true
      ));
    });

    on<AuthCheckEvent>(_onCheckAuth);
    on<AuthLoginEvent>(_onLogin);
    on<AuthTwoFactorCodeSubmittedEvent>(_onTwoFactorCodeSubmitted);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthTwoFactorResendEvent>(_onTwoFactorCodeResend);
    on<AuthTwoFactorRequiredEvent>(_onTwoFactorRequired);
  }

  @override
  Future<void> close() {
    _twoFactorSub?.cancel();
    return super.close();
  }

  Future<void> _onCheckAuth(
    AuthCheckEvent event,
    Emitter<AuthState> emit
  ) async {
    emit(AuthCheckingState());
    try {
      final user = await checkAuthUsecase.execute();

      if (user == null) {
        emit(AuthLoginState());
        return;
      }
      emit(AuthentificatedState(user));
    } catch (e) {
      emit(AuthLoginState());
    }
  }

  Future<void> _onTwoFactorRequired(
    AuthTwoFactorRequiredEvent event,
    Emitter<AuthState> emit
  ) async {
    emit(AuthTwoFactorState(
      login: event.login, 
      password: event.password,
      isBackground: event.isBackground
    ));
  }

  Future<void> _onLogin(
    AuthLoginEvent event,
    Emitter<AuthState> emit
  ) async {
    emit(AuthLoginState(isLoading: true));
    try {
      final user = await loginUseCase.execute(event.login, event.password);
      emit(AuthentificatedState(user));
    } on TwoFactorRequiredException catch (_) {
      add(AuthTwoFactorRequiredEvent(
        login: event.login, 
        password: event.password,
        isBackground: false
      ));
    } on AuthInvalidCredentialsException catch (_) {
      emit(AuthLoginState(isLoading: false, errorMessage: 'Неверный логин или пароль'));
    }
    catch (exception) {
      emit(AuthLoginState(isLoading: false, errorMessage: 'Ошибка подключения'));
    }
  }

  Future<void> _onTwoFactorCodeResend(
    AuthTwoFactorResendEvent event,
    Emitter<AuthState> emit
  ) async {
    final current = state;
    if (current is! AuthTwoFactorState) return;

    try {
      await loginUseCase.execute(current.login, current.password);
    } on TwoFactorRequiredException {
      // Ожидаемо — код отправлен заново, ничего не делаем
    } catch (e) {
      emit(current.copyWith(error: 'Не удалось отправить код'));
    }
  }

  Future<void> _onLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit
  ) async {
    await logoutUsecase.execute();
    emit(UnauthenticatedState());
  }

  Future<void> _onTwoFactorCodeSubmitted(
    AuthTwoFactorCodeSubmittedEvent event,
    Emitter<AuthState> emit
  ) async {
    final currentState = state as AuthTwoFactorState;
    emit(currentState.copyWith(isLoading: true, clearError: true));

    try {
      final user = await authByCodeUseCase.execute(
        login: currentState.login,
        password: currentState.password,
        code: event.code,
      );

      emit(AuthentificatedState(user));

    } catch (_) {
      emit(currentState.copyWith(
        isLoading: false,
        error: "Неверный код",
      ));
    }
  }
}