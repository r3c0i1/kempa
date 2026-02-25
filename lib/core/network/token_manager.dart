import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kempa/core/debug/debug_log.dart';

class TokenManager {
  final FlutterSecureStorage _storage;
  Completer<void>? _refreshCompleter;

  TokenManager(this._storage);

  Future<void> saveTokens({
    required String access,
    required String refresh
  }) async {
    DebugLog.instance.log('=== SAVE TOKENS ===');
    await _storage.write(key: 'accessToken', value: access);
    await _storage.write(key: 'refreshToken', value: refresh);
    final saved = await _storage.read(key: 'accessToken');
    DebugLog.instance.log('SAVED TOKEN: ${saved != null ? "OK" : "FAILED"}');
  }

  Future<void> saveCredentials({
    required String login,
    required String password
  }) async {
    await _storage.write(key: 'login', value: login);
    await _storage.write(key: 'password', value: password);
  }

  Future<void> clearTokens() async {
    DebugLog.instance.log('=== CLEAR TOKENS CALLED ===');
    // DebugLog.instance.log(StackTrace.current.toString());
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: 'login');
    await _storage.delete(key: 'password');
  }

  Future<void> clearAll() async {
    await clearTokens();
    await clearCredentials();
  }

  Future<String?> getAccessToken() async {
    final token = await _storage.read(key: 'accessToken');
    DebugLog.instance.log('GET TOKEN: ${token != null ? "exists" : "NULL"}');
    return token;
  }

  Future<void> refreshTokens() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer();

    try {
      // Шаг 1: пробуем refresh
      await _tryRefresh();
      _refreshCompleter!.complete();
    } catch (e) {
      // Шаг 2: refresh не удался — пробуем re-login
      try {
        await _tryReLogin();
        _refreshCompleter!.complete();
      } catch (reLoginError) {
        // Оба способа не сработали
        await clearAll();
        _refreshCompleter!.completeError(reLoginError);
        rethrow;
      }
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<void> _tryRefresh() async {
    final access = await _storage.read(key: 'accessToken');
    final refresh = await _storage.read(key: 'refreshToken');

    if (access == null || refresh == null) {
      throw Exception('No tokens');
    }

    final dio = Dio();
    dio.options.headers = {
      'Origin': 'https://api-next.kemsu.ru',
    };

    final res = await dio.post(
      'https://api-next.kemsu.ru/api/refresh-token',
      data: {
        'accessToken': access,
        'refreshToken': refresh,
        'lifetime': '30d',
      },
    );

    await saveTokens(
      access: res.data['accessToken'],
      refresh: res.data['refreshToken'],
    );
  }

  Future<void> _tryReLogin() async {
    final login = await _storage.read(key: 'login');
    final password = await _storage.read(key: 'password');

    if (login == null || password == null) {
      throw Exception('No credentials');
    }

    final dio = Dio();
    dio.options.headers = {
      'Origin': 'https://api-next.kemsu.ru',
    };

    final res = await dio.post(
      'https://api-next.kemsu.ru/api/auth',
        data: {
          'login': login,
          'password': password,
          'lifetime': '30d',
        },
    );

    final data = res.data as Map<String, dynamic>;

    if (data['success'] == true) {
      await saveTokens(
        access: data['accessToken'],
        refresh: data['refreshToken'],
      );
    } else {
      throw Exception('Re-login failed');
    }
  }
}