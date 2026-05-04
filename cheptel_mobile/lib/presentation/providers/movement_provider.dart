import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../data/datasources/remote/api_client.dart';
import '../../data/models/movement_model.dart';
import '../../services/sync_service.dart';

class MovementProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final SyncService _syncService = SyncService();

  bool _isLoading = false;
  String? _error;
  String? _success;
  List<MovementModel> _movements = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get success => _success;
  List<MovementModel> get movements => _movements;

  Future<void> loadByAnimal(int animalId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get(
        '/movements/animal/$animalId',
      );

      final list = response.data as List;
      _movements = list
          .map((e) => MovementModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        _error = data['message'].toString();
      } else {
        _error = "Erreur chargement mouvements";
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createMovement(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    _success = null;
    notifyListeners();

    debugPrint("=== ENVOI MOUVEMENT ===");
    debugPrint("Payload : $data");

    try {
      // ENVOI DIRECT au backend (pas de check isOnline)
      final response = await _apiClient.dio.post(
        '/movements',
        data: data,
      );

      debugPrint("✅ Réponse backend : ${response.data}");

      _success = "Mouvement enregistré avec succès";
      return true;
    } on DioException catch (e) {
      debugPrint("❌ DioException : ${e.message}");
      debugPrint("❌ Response : ${e.response?.data}");

      // Si erreur réseau réelle, sauvegarder offline
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        try {
          await _syncService.saveMovementOffline(data);
          _success = "Pas de connexion. Mouvement sauvegardé localement.";
          return true;
        } catch (offlineError) {
          _error = "Erreur réseau : ${e.message}";
          return false;
        }
      }

      // Sinon afficher l'erreur backend
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic> && responseData['message'] != null) {
        _error = responseData['message'].toString();
      } else {
        _error = "Erreur création mouvement (code ${e.response?.statusCode})";
      }
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint("❌ Erreur inconnue : $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _error = null;
    _success = null;
    notifyListeners();
  }
}