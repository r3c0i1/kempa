import 'dart:async';

import 'package:kempa/features/auth/domain/entities/auth_result.dart';
import 'package:kempa/features/auth/domain/entities/auth_session_state.dart';
import 'package:kempa/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Stream<AuthSessionState> get sessionStream;
  UserEntity? get currentUser;

  Future<void> checkAuthStatus();

  Future<AuthResult> login({
    required String login,
    required String password,
  });

  Future<AuthResult> authByCode({
    required String login,
    required String password,
    required String code,
  });

  Future<void> logout();

  Future<bool> refreshSession();
}