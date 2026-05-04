import 'package:dio/dio.dart';
import '../datasources/remote/api_client.dart';
import '../models/constat_request.dart';
import '../../core/constants/api_constants.dart';

class ConstatRepository {
  final ApiClient _apiClient = ApiClient();

  Future<void> createConstat(ConstatRequest request) async {
    try {
      await _apiClient.dio.post(
        ApiConstants.constats,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, "Erreur lors de l'envoi du constat"));
    }
  }

  String _extractErrorMessage(DioException e, String defaultMessage) {
    if (e.response != null) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ?? defaultMessage;
      }

      if (data is String && data.isNotEmpty) {
        return data;
      }

      return '$defaultMessage (Code: ${e.response?.statusCode})';
    }

    return defaultMessage;
  }
}