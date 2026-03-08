import 'dart:async';
import 'package:kempa/features/auth/domain/entities/auth_session_state.dart';
import 'package:kempa/features/auth/domain/repositories/auth_repository.dart';
import 'package:rxdart/rxdart.dart';

import 'package:kempa/core/network/auth_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/auth_result.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local; 
  final AuthStorage _storage;       

  final _sessionSubject = BehaviorSubject<AuthSessionState>.seeded(const SessionNone());

  Completer<bool>? _refreshCompleter;

  AuthRepositoryImpl(this._remote, this._local, this._storage);

  @override
  Stream<AuthSessionState> get sessionStream => _sessionSubject.stream;
  
  @override
  UserEntity? get currentUser {
    final state = _sessionSubject.value;
    if (state is SessionActive) return state.user;
    return null;
  }

  @override
  Future<AuthResult> login({required String login, required String password}) async {
    try {
      final res = await _remote.login(login, password);
      
      if (!res.success) return const AuthFailure('Неверный логин или пароль');
      
      if (res.twoFactorAuthEnabled == true && res.accessToken == null) {
        return AuthRequires2FA(login: login, password: password);
      }

      await _saveSessionAndUser(res, login, password);
      return AuthSuccess(currentUser!);
      
    } catch (e) {
      return const AuthFailure('Ошибка сети');
    }
  }

  @override
  Future<AuthResult> authByCode({required String login, required String password, required String code}) async {
    try {
      final res = await _remote.authByCode(login, code);
      if (!res.success) return const AuthFailure('Неверный код');
      
      await _saveSessionAndUser(res, login, password);
      return AuthSuccess(currentUser!);
    } catch (e) {
      return const AuthFailure('Ошибка сети');
    }
  }

  @override
  Future<void> checkAuthStatus() async {
    final token = await _storage.getAccessToken();
    final cachedUser = await _local.getUser();

    if (token != null && cachedUser != null) {
      _sessionSubject.add(SessionActive(cachedUser)); 
    } else {
      await logout(); 
    }
  }

  @override
  Future<void> logout() async {
    await _storage.clearAll();
    await _local.clearUser();

    _sessionSubject.add(const SessionNone());
  }

  @override
  Future<bool> refreshSession() async {
    if (_refreshCompleter != null) return _refreshCompleter!.future;
    _refreshCompleter = Completer<bool>();

    try {
      final access = await _storage.getAccessToken();
      final refresh = await _storage.getRefreshToken();
      
      if (access != null && refresh != null) {
        final res = await _remote.refreshToken(access, refresh);
        if (res.success && res.accessToken != null) {
          await _storage.saveTokens(res.accessToken!, res.refreshToken!);
          _refreshCompleter!.complete(true);
          return true;
        }
      }

      final creds = await _storage.getCredentials();
      if (creds != null) {
        final res = await _remote.login(creds.login, creds.password);
        
        if (res.twoFactorAuthEnabled == true && res.accessToken == null) {
          _sessionSubject.add(SessionSuspendedFor2FA(creds.login, creds.password));
          _refreshCompleter!.complete(false); 
          return false;
        }

        if (res.success && res.accessToken != null) {
          await _saveSessionAndUser(res, creds.login, creds.password);
          _refreshCompleter!.complete(true);
          return true;
        }
      }

      throw Exception("Session cannot be restored");
    } catch (e) {
      await logout();
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<void> _saveSessionAndUser(dynamic res, String login, String pass) async {
    await _storage.saveTokens(res.accessToken!, res.refreshToken!);
    await _storage.saveCredentials(login, pass);
    
    final user = res.userInfo!.toEntity();
    await _local.saveUser(user);
    
    _sessionSubject.add(SessionActive(user)); 
  }

  void dispose() {
    _sessionSubject.close();
  }
}