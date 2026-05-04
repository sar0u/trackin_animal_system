import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/login_response.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/utils/token_storage.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;
  String? _error;
  String? _success;
  LoginResponse? _user;

  bool _rememberMe = false;
  bool _acceptTerms = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get success => _success;
  LoginResponse? get user => _user;

  bool get rememberMe => _rememberMe;
  bool get acceptTerms => _acceptTerms;

  // ==========================
  // UI STATE
  // ==========================

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void setAcceptTerms(bool value) {
    _acceptTerms = value;
    notifyListeners();
  }

  void clearMessages() {
    _error = null;
    _success = null;
    notifyListeners();
  }

  // ==========================
  // LOGIN
  // ==========================

  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    _error = null;
    _success = null;
    notifyListeners();

    try {
      final loginResponse = await _authRepository.login(
        identifier,
        password,
      );

      // ✅ Bloquer ADMIN dans l'application mobile
      if (loginResponse.role == 'ADMIN') {
        throw Exception("Le profil administrateur est réservé à l'interface web.");
      }

      await TokenStorage.saveLoginData(
        token: loginResponse.token,
        role: loginResponse.role,
        username: loginResponse.username,
        farmId: loginResponse.farmId,
        rememberMe: _rememberMe,
      );

      _user = loginResponse;

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==========================
  // REGISTER
  // ==========================

  Future<bool> register({
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    _success = null;
    notifyListeners();

    try {
      final message = await _authRepository.register(
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        role: role,
      );

      _success = message;

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==========================
  // FORGOT PASSWORD
  // ==========================

  Future<bool> forgotPassword(String contact) async {
    _isLoading = true;
    _error = null;
    _success = null;
    notifyListeners();

    try {
      final message = await _authRepository.forgotPassword(contact);

      _success = message;

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyResetCode(String contact, String code) async {
    _isLoading = true;
    _error = null;
    _success = null;
    notifyListeners();

    try {
      await _authRepository.verifyResetCode(contact, code);

      _success = "Code vérifié avec succès";

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(
      String contact,
      String code,
      String newPassword,
      ) async {
    _isLoading = true;
    _error = null;
    _success = null;
    notifyListeners();

    try {
      await _authRepository.resetPassword(
        contact,
        code,
        newPassword,
      );

      _success = "Mot de passe réinitialisé avec succès";

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==========================
  // REMEMBER ME
  // ==========================

  Future<String?> getSavedIdentifier() async {
    final prefs = await SharedPreferences.getInstance();

    final remember = prefs.getBool('remember_me') ?? false;

    if (remember) {
      _rememberMe = true;
      notifyListeners();
      return prefs.getString('saved_identifier');
    }

    return null;
  }

  // ==========================
  // LOGOUT
  // ==========================

  Future<void> logout() async {
    await TokenStorage.clear();

    _user = null;
    _rememberMe = false;
    _acceptTerms = false;
    _error = null;
    _success = null;

    notifyListeners();
  }
}