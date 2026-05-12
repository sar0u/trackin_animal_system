import 'package:dio/dio.dart';

import '../datasources/remote/api_client.dart';
import '../models/control_check_response.dart';
import '../../core/constants/api_constants.dart';

class ControleurRepository {
  final ApiClient _apiClient = ApiClient();

  Future<ControlCheckResponse> checkEffectif(
      int farmId,
      List<String> scannedTags,
      ) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.controleurCheck,
        data: {
          "farmId": farmId,
          "scannedRfidTags": scannedTags,
        },
      );

      return ControlCheckResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message']);
      }

      if (data is String && data.isNotEmpty) {
        throw Exception(data);
      }

      throw Exception("Erreur lors du CHECK");
    }
  }
}