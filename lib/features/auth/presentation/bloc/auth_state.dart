import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthChecking extends AuthState {}

class AuthSuccess extends AuthState {
  final UserEntity user;
  AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthRequiresTwoFactor extends AuthState {
  final String login;
  final String password;
  final bool isVerifying;
  final String? error;

  AuthRequiresTwoFactor({
    required this.login,
    required this.password,
    this.isVerifying = false,
    this.error,
  });

  AuthRequiresTwoFactor copyWith({
    String? login,
    String? password,
    bool? isVerifying,
    String? error,
    bool clearError = false,
  }) {
    return AuthRequiresTwoFactor(
      login: login ?? this.login,
      password: password ?? this.password,
      isVerifying: isVerifying ?? this.isVerifying,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [login, password, isVerifying, error];
}

class Unauthenticated extends AuthState {}