import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kempa/core/network/auth_storage.dart';

class ApiClient {
  final Dio _dio = Dio();
  final AuthStorage _storage;
  final Future<bool> Function() onTokenExpired; 

  ApiClient(this._storage, this.onTokenExpired) {
    _dio.options.baseUrl = 'https://api-next.kemsu.ru/api';
    _dio.options.headers = {
      'Origin': 'https://api-next.kemsu.ru'
    };

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getAccessToken();
        debugPrint('TOKEN: ${token != null ? "exists" : "NULL"}');
        debugPrint('PATH: ${options.path}');
        if (token != null) options.headers['x-access-token'] = token;
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {

          final isRestored = await onTokenExpired();
          
          if (isRestored) {
            final newToken = await _storage.getAccessToken();
            error.requestOptions.headers['x-access-token'] = newToken;
            
            try {
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
        }
        return handler.next(error);
      },
    ));
  }

  Future<Response> post(String path, {dynamic data}) => _dio.post(path, data: data);
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) => _dio.get(path, queryParameters: queryParameters);
}