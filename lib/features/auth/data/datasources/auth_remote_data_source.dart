import 'package:dio/dio.dart';
import 'package:kempa/features/auth/domain/exceptions/auth_invalid_credentials_exception.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String login, String password);
  Future<AuthResponseModel> authByCode(String login, String code);
  Future<AuthResponseModel> refreshToken(String access, String refresh);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api-next.kemsu.ru/api',
    headers: {'Origin': 'https://api-next.kemsu.ru'},
  ));

  @override
  Future<AuthResponseModel> login(String login, String password) async {
    try {
      final response = await _dio.post('/auth', data: {
        'login': login,
        'password': password,
        "lifetime": "30d"
      });
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      switch (e.response?.statusCode){
        case 401:
          throw AuthInvalidCredentialsException();
        default:
          throw Exception("Ошибка подключения");
      }
    }
  }
  
  @override
  Future<AuthResponseModel> authByCode(String login, String code) async {
    try {
      final response = await _dio.post('/auth-by-code', data: {
        'login': login,
        'code': code,
        "lifetime": "30d"
      });
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      switch (e.response?.statusCode){
        case 400:
          throw Exception("Некорретный код");
        default:
          throw Exception("Ошибка подключения");
      }
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(String access, String refresh) async {
    final response = await _dio.post('/refresh-token', data: {
      'accessToken': access,
      'refreshToken': refresh,
      'lifetime': '30d'
    });
    return AuthResponseModel.fromJson(response.data);
  }
}