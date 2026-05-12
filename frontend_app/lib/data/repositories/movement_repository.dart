import 'package:dio/dio.dart';

import '../datasources/remote/api_client.dart';
import '../models/movement_model.dart';

class MovementRepository {
  final ApiClient _apiClient = ApiClient();

  Future<MovementModel> createMovement(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        '/movements',
        data: data,
      );

      return MovementModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_extractMessage(e, "Erreur création mouvement"));
    }
  }

  Future<List<MovementModel>> getMovementsByAnimal(int animalId) async {
    try {
      final response = await _apiClient.dio.get(
        '/movements/animal/$animalId',
      );

      final list = response.data as List;
      return list.map((e) => MovementModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(_extractMessage(e, "Erreur chargement mouvements"));
    }
  }

  String _extractMessage(DioException e, String defaultMessage) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'].toString();
    }
    if (data is String && data.isNotEmpty) {
      return data;
    }
    return defaultMessage;
  }
}