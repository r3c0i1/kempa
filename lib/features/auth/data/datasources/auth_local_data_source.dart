import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kempa/features/auth/data/models/auth_response_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens({required String access, required String refresh});
  Future<String?> getAccessToken();
  Future<void> cacheUser(UserInfoModel user);
  Future<UserInfoModel?> getCachedUser();
  Future<void> clear();  
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  
  final FlutterSecureStorage storage;

  AuthLocalDataSourceImpl(this.storage);

  @override
  Future<void> saveTokens({
    required String access,
    required String refresh
  }) async {
    await storage.write(key: 'accessToken', value: access);
    await storage.write(key: 'refreshToken', value: refresh);
  }

  @override
  Future<String?> getAccessToken() => storage.read(key: 'accessToken');

  @override
  Future<void> clear() => storage.deleteAll();
  
  @override
  Future<void> cacheUser(UserInfoModel user) async {
    await storage.write(key: 'cachedUser', value: jsonEncode(user.toJson()));
  }
  
  @override
  Future<UserInfoModel?> getCachedUser() async {
    final data = await storage.read(key: 'cachedUser');
    return data != null ? UserInfoModel.fromJson(jsonDecode(data)) : null;
  }
}