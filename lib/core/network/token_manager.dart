import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  final FlutterSecureStorage _storage;
  Completer<void>? _refreshCompleter;

  TokenManager(this._storage);

  Future<void> saveTokens({
    required String access,
    required String refresh
  }) async {
    await _storage.write(key: 'accessToken', value: access);
    await _storage.write(key: 'refreshToken', value: refresh);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }

  Future<String?> getAccessToken() => _storage.read(key: 'accessToken');

  Future<void> refreshTokens() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    _refreshCompleter = Completer();
    final access = await _storage.read(key: 'accessToken');
    final refresh = await _storage.read(key: 'refreshToken');
    if (access == null || refresh == null) {
      _refreshCompleter?.complete();
      _refreshCompleter = null;
      return;
    }

    try {
      final dio = Dio();
      dio.options.headers = {
        'Origin': 'https://api-next.kemsu.ru'
      };
      final res = await dio.post(
        'https://api-next.kemsu.ru/api/refresh-token',
        data: {
          'accessToken': access,
          'refreshToken': refresh,
          "lifetime": "30d"
        },
      );
      await saveTokens(access: res.data['accessToken'], refresh: res.data['refreshToken']);
      _refreshCompleter!.complete();
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        await clearTokens();
      }
      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  } 
}