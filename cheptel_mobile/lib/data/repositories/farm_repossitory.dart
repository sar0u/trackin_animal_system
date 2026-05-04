import 'package:dio/dio.dart';

import '../datasources/remote/api_client.dart';
import '../models/farm_model.dart';

class FarmRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<FarmModel>> getFarms() async {
    try {
      final response = await _apiClient.dio.get('/farms');

      final list = response.data as List;

      return list
          .map((e) => FarmModel.fromJson(e as Map<String, dynamic>))
          .where((farm) => farm.id != 0)
          .toList();
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message']);
      }

      throw Exception("Impossible de charger les fermes");
    }
  }
}