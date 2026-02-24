import 'package:dio/dio.dart';
import 'package:kempa/core/network/token_manager.dart';

class ApiClient {
  final Dio _dio = Dio();
  final TokenManager _tokenManager;

  ApiClient(this._tokenManager) {
    _dio.options.baseUrl = 'https://api-next.kemsu.ru/api';
    _dio.options.headers = {
      'Origin': 'https://api-next.kemsu.ru'
    };

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenManager.getAccessToken();
        if (token != null) options.headers['x-access-token'] = token;
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          print('401 caught for: ${error.requestOptions.path}');
          final requestPath = error.requestOptions.path;

          if (requestPath.contains('/auth') ||
              requestPath.contains('/refresh-token')) {
            return handler.next(error);
          }

          try {
            await _tokenManager.refreshTokens();
            final newToken = await _tokenManager.getAccessToken();
            if (newToken != null) {
              error.requestOptions.headers['x-access-token'] = newToken;
              return handler.resolve(await _dio.fetch(error.requestOptions));
            }
          } catch(_) {
            return handler.next(error);
          }
        }
        return handler.next(error);
      },
    ));
  }

  Future<Response> post(String path, {dynamic data}) => _dio.post(path, data: data);
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) => _dio.get(path, queryParameters: queryParameters);
}