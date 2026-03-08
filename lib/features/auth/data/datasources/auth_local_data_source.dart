import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kempa/features/auth/domain/entities/user_entity.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(UserEntity user);
  Future<UserEntity?> getUser();
  Future<void> clearUser();  
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  
  final FlutterSecureStorage storage;

  AuthLocalDataSourceImpl(this.storage);

  @override
  Future<void> clearUser() async {
    await storage.delete(key: 'user');
  }
  
  @override
  Future<UserEntity?> getUser() async {
    final data = await storage.read(key: 'user');
    return data != null ? UserEntity.fromJson(jsonDecode(data)) : null;
  }
  
  @override
  Future<void> saveUser(UserEntity user) async {
    await storage.write(key: 'user', value: jsonEncode(user.toJson()));
  }
}