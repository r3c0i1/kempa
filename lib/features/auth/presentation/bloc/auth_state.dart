import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthCheckingState extends AuthState {}

class UnauthenticatedState extends AuthState {}

class AuthentificatedState extends AuthState {
  final UserEntity user;
  AuthentificatedState(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthLoginState extends AuthState {
  final bool isLoading;
  final String? errorMessage;

  AuthLoginState({this.isLoading = false, this.errorMessage});

  @override
  List<Object?> get props => [isLoading, errorMessage];
}

class AuthTwoFactorState extends AuthState {
  final String login;
  final String password;
  final bool isBackground;
  final bool isLoading;
  final String? error;

  AuthTwoFactorState({
    required this.login,
    required this.password,
    this.isBackground = false,
    this.isLoading = false,
    this.error,
  });

  AuthTwoFactorState copyWith({
    String? login,
    String? password,
    bool? isBackground,
    String? error,
    bool? isLoading,
    bool clearError = false,
  }) {
    return AuthTwoFactorState(
      login: login ?? this.login,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      isBackground: isBackground ?? this.isBackground,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [login, password, isBackground, error, isLoading];
}

