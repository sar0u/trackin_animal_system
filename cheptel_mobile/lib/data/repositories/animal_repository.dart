import 'package:dio/dio.dart';

import '../datasources/remote/api_client.dart';
import '../models/animal_model.dart';
import '../../core/constants/api_constants.dart';
import '../../services/sync_service.dart';

class AnimalRepository {
  final ApiClient _apiClient = ApiClient();
  final SyncService _syncService = SyncService();

  Future<AnimalModel> getAnimalByRfid(String rfidTag) async {
    try {
      final encodedRfid = Uri.encodeComponent(rfidTag);

      final response = await _apiClient.dio.get(
        '${ApiConstants.animalByRfid}$encodedRfid',
      );

      final animal = AnimalModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Sauvegarder en cache local
      await _syncService.cacheAnimal(animal);

      return animal;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception("Cet animal n'appartient pas à votre exploitation");
      }

      if (e.response?.statusCode == 404) {
        throw Exception("Animal introuvable");
      }

      // Erreur réseau → cache local
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        final cached = await _syncService.getAnimalFromCache(rfidTag);
        if (cached != null) return cached;
        throw Exception("Animal introuvable (mode hors ligne)");
      }

      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message']);
      }

      throw Exception("Erreur lors de la récupération de l'animal");
    } catch (e) {
      if (e is Exception) rethrow;

      final cached = await _syncService.getAnimalFromCache(rfidTag);
      if (cached != null) return cached;

      throw Exception("Erreur inconnue");
    }
  }

  Future<AnimalModel> createAnimal(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.createAnimal,
        data: data,
      );

      return AnimalModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message']);
      }
      throw Exception("Erreur lors de la création de l'animal");
    }
  }

  Future<AnimalModel> updateAnimal(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put(
        '/animals/$id',
        data: data,
      );

      return AnimalModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message']);
      }
      throw Exception("Erreur lors de la modification");
    }
  }
}