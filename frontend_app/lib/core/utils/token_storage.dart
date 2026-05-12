import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'access_token';
  static const _roleKey = 'user_role';
  static const _usernameKey = 'username';
  static const _farmIdKey = 'farm_id';
  static const _rememberKey = 'remember_me';

  static String normalizeRole(String role) {
    switch (role) {
      case 'Farmer':        return 'FERMIER';
      case 'Veterinarian':  return 'VETERINAIRE';
      case 'Inspector':     return 'CONTROLEUR';
      case 'Administrator': return 'ADMIN';
      default:              return role.toUpperCase();
    }
  }

  // Sauvegarder les données de connexion
  static Future<void> saveLoginData({
    required String token,
    required String role,
    required String username,
    int? farmId,
    bool rememberMe = false,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _roleKey, value: normalizeRole(role));
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _rememberKey, value: rememberMe.toString());

    if (farmId != null) {
      await _storage.write(key: _farmIdKey, value: farmId.toString());
    }
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  static Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  static Future<int?> getFarmId() async {
    final value = await _storage.read(key: _farmIdKey);
    return value != null ? int.tryParse(value) : null;
  }

  static Future<bool> isRemembered() async {
    final value = await _storage.read(key: _rememberKey);
    return value == 'true';
  }

  static Future<bool> hasValidSession() async {
    final token = await getToken();
    final remember = await isRemembered();
    return token != null && token.isNotEmpty && remember;
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }

  // Effacer SAUF "remember_me" (en cas de logout volontaire)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}