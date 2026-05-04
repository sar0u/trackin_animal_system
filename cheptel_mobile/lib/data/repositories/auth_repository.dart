import 'package:dio/dio.dart';

import '../datasources/remote/api_client.dart';
import '../models/login_response.dart';
import '../../core/constants/api_constants.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  // ======================
  // LOGIN
  // ======================

  Future<LoginResponse> login(
      String identifier,
      String password,
      ) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.login,
        data: {
          'identifier': identifier,
          'password': password,
        },
      );

      return LoginResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(
        _extractMessage(e, 'Identifiants invalides'),
      );
    }
  }

  // ======================
  // REGISTER
  // ======================

  Future<String> register({
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
          'role': role,
        },
      );

      return response.data['message']?.toString() ??
          'Compte créé avec succès';
    } on DioException catch (e) {
      throw Exception(
        _extractMessage(e, "Erreur lors de l'inscription"),
      );
    }
  }

  // ======================
  // FORGOT PASSWORD
  // ======================

  Future<String> forgotPassword(String contact) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/forgot-password',
        data: {
          'contact': contact,
        },
      );

      return response.data['message']?.toString() ??
          'Code envoyé si le compte existe';
    } on DioException catch (e) {
      throw Exception(
        _extractMessage(e, 'Erreur lors de l’envoi du code'),
      );
    }
  }

  Future<void> verifyResetCode(
      String contact,
      String code,
      ) async {
    try {
      await _apiClient.dio.post(
        '/auth/verify-reset-code',
        data: {
          'contact': contact,
          'code': code,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        _extractMessage(e, 'Code invalide ou expiré'),
      );
    }
  }

  Future<void> resetPassword(
      String contact,
      String code,
      String newPassword,
      ) async {
    try {
      await _apiClient.dio.post(
        '/auth/reset-password',
        data: {
          'contact': contact,
          'code': code,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        _extractMessage(e, 'Erreur lors de la réinitialisation'),
      );
    }
  }

  // ======================
  // ERROR PARSER
  // ======================

  String _extractMessage(
      DioException e,
      String defaultMessage,
      ) {
    if (e.response != null) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ?? defaultMessage;
      }

      if (data is String && data.isNotEmpty) {
        return data;
      }

      return '$defaultMessage (${e.response?.statusCode})';
    }

    return 'Impossible de se connecter au serveur';
  }
}
