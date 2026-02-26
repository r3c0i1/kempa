import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String login;
  final String password;

  LoginRequested({required this.login, required this.password});

  @override
  List<Object?> get props => [login, password];
}

class AuthCheckRequested extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

class AuthUpdateRequested extends AuthEvent {}

class TwoFactorCodeSubmitted extends AuthEvent {
  final String code;

  TwoFactorCodeSubmitted(this.code);

  @override
  List<Object?> get props => [code];
}