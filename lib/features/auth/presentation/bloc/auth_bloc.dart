import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kempa/features/auth/domain/entities/auth_session_state.dart';

import 'package:kempa/features/auth/domain/repositories/auth_repository.dart';
import 'package:kempa/features/auth/domain/entities/auth_result.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  late final StreamSubscription _authSubscription;

  AuthBloc({
    required this.authRepository,
  }) : super(AuthInitialState()) {
    
    _authSubscription = authRepository.sessionStream.listen((sessionState) {
      add(AuthSessionStatusChangedEvent(sessionState));
    });

    on<AuthCheckEvent>(_onCheckAuth);
    on<AuthSessionStatusChangedEvent>(_onAuthStatusChanged);
    on<AuthLoginEvent>(_onLogin);
    on<AuthTwoFactorCodeSubmittedEvent>(_onTwoFactorCodeSubmitted);
    on<AuthTwoFactorResendEvent>(_onTwoFactorCodeResend);
    on<AuthLogoutEvent>(_onLogout);
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }

  void _onAuthStatusChanged(
    AuthSessionStatusChangedEvent event,
    Emitter<AuthState> emit
  ) {
    switch (event.state) {
      case SessionNone():
        emit(UnauthenticatedState());
        
      case SessionActive(user: final u):
        emit(AuthentificatedState(u));
        
      case SessionSuspendedFor2FA(login: final l, password: final p):
        emit(AuthTwoFactorState(
          login: l, 
          password: p, 
          isBackground: true
        ));
    }
  }

  Future<void> _onCheckAuth(
    AuthCheckEvent event,
    Emitter<AuthState> emit
  ) async {
    emit(AuthCheckingState());
    await authRepository.checkAuthStatus();
  }

  Future<void> _onLogin(
    AuthLoginEvent event,
    Emitter<AuthState> emit
  ) async {
    emit(AuthLoginState(isLoading: true));
    
    final result = await authRepository.login(
      login: event.login, 
      password: event.password,
    );

    switch (result) {
      case AuthSuccess():
        break;
        
      case AuthRequires2FA():
        emit(AuthTwoFactorState(
          login: result.login, 
          password: result.password,
        ));
        
      case AuthFailure():
        emit(AuthLoginState(
          isLoading: false, 
          errorMessage: result.message,
        ));
    }
  }

  Future<void> _onTwoFactorCodeSubmitted(
    AuthTwoFactorCodeSubmittedEvent event,
    Emitter<AuthState> emit
  ) async {
    final currentState = state;
    if (currentState is! AuthTwoFactorState) return;

    emit(currentState.copyWith(isLoading: true, clearError: true));

    final result = await authRepository.authByCode(
      login: currentState.login,
      password: currentState.password,
      code: event.code,
    );

    switch (result) {
      case AuthSuccess():
        break;
      case AuthRequires2FA():
        // Технически невозможно, но switch требует обработать
        break; 
      case AuthFailure():
        emit(currentState.copyWith(
          isLoading: false,
          error: result.message,
        ));
    }
  }

  Future<void> _onTwoFactorCodeResend(
    AuthTwoFactorResendEvent event,
    Emitter<AuthState> emit
  ) async {
    final currentState = state;
    if (currentState is! AuthTwoFactorState) return;

    final result = await authRepository.login(
      login: currentState.login, 
      password: currentState.password
    );

    if (result is AuthFailure) {
      emit(currentState.copyWith(error: 'Не удалось отправить код'));
    }
  }

  Future<void> _onLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit
  ) async {
    await authRepository.logout();
  }
}