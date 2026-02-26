import 'package:dio/dio.dart';
import 'package:kempa/core/network/token_manager.dart';

import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String login, String password);
  Future<void> updateTokens();
  Future<AuthResponseModel> authByCode(String login, String code);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _client;
  final TokenManager _tokenManager;
  AuthRemoteDataSourceImpl(this._client, this._tokenManager);

  @override
  Future<AuthResponseModel> login(String login, String password) async {
    try {
      final response = await _client.post('/auth', data: {
        'login': login,
        'password': password,
        "lifetime": "30d"
      });
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      switch (e.response?.statusCode){
        case 401:
          throw Exception("Неверный логин или пароль");
        default:
          throw Exception("Ошибка подключения");
      }
    }
  }
  
  @override
  Future<void> updateTokens() async {
    await _tokenManager.refreshTokens();
  }
  
  @override
  Future<AuthResponseModel> authByCode(String login, String code) async {
    try {
      final response = await _client.post('/auth-by-code', data: {
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
}