import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  final FlutterSecureStorage _storage;

  const AuthStorage(this._storage);

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'accessToken', value: access);
    await _storage.write(key: 'refreshToken', value: refresh);
  }

  Future<void> saveCredentials(String login, String password) async {
    await _storage.write(key: 'login', value: login);
    await _storage.write(key: 'password', value: password);
  }

  Future<String?> getAccessToken() => _storage.read(key: 'accessToken');
  Future<String?> getRefreshToken() => _storage.read(key: 'refreshToken');
  
  Future<({String login, String password})?> getCredentials() async {
    final login = await _storage.read(key: 'login');
    final password = await _storage.read(key: 'password');
    if (login != null && password != null) return (login: login, password: password);
    return null;
  }

  Future<void> clearAll() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    await _storage.delete(key: 'login');
    await _storage.delete(key: 'password');
  }
}