import 'package:dio/dio.dart';
import '../datasources/remote/api_client.dart';
import '../models/health_sheet_model.dart';
import '../../core/constants/api_constants.dart';

class VeterinaireRepository {
  final ApiClient _apiClient = ApiClient();

  Future<HealthSheetModel> getHealthSheet(String rfidTag) async {
    try {
      final encodedRfid = Uri.encodeComponent(rfidTag);
      final response = await _apiClient.dio.get(
        '${ApiConstants.veterinaireHealth}$encodedRfid/health',
      );
      return HealthSheetModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, "Erreur lors de la récupération de la fiche santé"));
    }
  }

  Future<VaccinationDto> addVaccination(String rfidTag, Map<String, dynamic> data) async {
    try {
      final encodedRfid = Uri.encodeComponent(rfidTag);
      final response = await _apiClient.dio.post(
        '${ApiConstants.addVaccination}$encodedRfid/vaccinations',
        data: data,
      );
      return VaccinationDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, "Erreur lors de l'ajout du vaccin"));
    }
  }

  Future<HealthRecordDto> addHealthRecord(String rfidTag, Map<String, dynamic> data) async {
    try {
      final encodedRfid = Uri.encodeComponent(rfidTag);
      final response = await _apiClient.dio.post(
        '${ApiConstants.addHealthRecord}$encodedRfid/health-records',
        data: data,
      );
      return HealthRecordDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, "Erreur lors de l'ajout de la consultation"));
    }
  }

  // ✅ Méthode utilitaire pour extraire le message d'erreur en toute sécurité
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