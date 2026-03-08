import 'package:kempa/features/auth/domain/entities/user_entity.dart';

sealed class AuthResult {
  const AuthResult();
}

class AuthSuccess extends AuthResult {
  final UserEntity user;
  const AuthSuccess(this.user);
}

class AuthRequires2FA extends AuthResult {
  final String login;
  final String password;
  
  const AuthRequires2FA({
    required this.login, 
    required this.password,
  });
}

class AuthFailure extends AuthResult {
  final String message;
  const AuthFailure(this.message);
}