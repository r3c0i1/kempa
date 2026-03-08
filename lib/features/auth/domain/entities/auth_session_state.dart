import 'user_entity.dart';

sealed class AuthSessionState {
  const AuthSessionState();
}

class SessionNone extends AuthSessionState {
  const SessionNone();
}

class SessionActive extends AuthSessionState {
  final UserEntity user;
  const SessionActive(this.user);
}

class SessionSuspendedFor2FA extends AuthSessionState {
  final String login;
  final String password;
  const SessionSuspendedFor2FA(this.login, this.password);
}