import 'package:equatable/equatable.dart';
import 'package:kempa/features/auth/domain/entities/auth_session_state.dart';
import 'package:kempa/features/auth/domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckEvent extends AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String login;
  final String password;

  AuthLoginEvent({required this.login, required this.password});

  @override
  List<Object?> get props => [login, password];
}

class AuthTwoFactorCodeSubmittedEvent extends AuthEvent {
  final String code;

  AuthTwoFactorCodeSubmittedEvent(this.code);

  @override
  List<Object?> get props => [code];
}

class AuthLogoutEvent extends AuthEvent {}

class AuthTwoFactorResendEvent extends AuthEvent {}

class AuthSessionStatusChangedEvent extends AuthEvent {
  final AuthSessionState state;
  AuthSessionStatusChangedEvent(this.state);
}