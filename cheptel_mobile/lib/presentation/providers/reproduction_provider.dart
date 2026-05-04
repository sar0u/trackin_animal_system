import 'package:flutter/material.dart';
import '../../services/sync_service.dart';
import '../../data/datasources/remote/api_client.dart';
import 'package:dio/dio.dart';

class ReproductionProvider with ChangeNotifier {
  final SyncService _syncService = SyncService();
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  String? _error;
  String? _success;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get success => _success;

  Future<bool> createReproduction(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    _success = null;
    notifyListeners();

    try {
      final online = await _syncService.isOnline();

      if (online) {
        await _apiClient.dio.post('/reproductions', data: data);
        _success = "Suivi reproductif enregistré";
      } else {
        await _syncService.saveReproductionOffline(data);
        _success = "Suivi reproductif sauvegardé hors ligne";
      }

      return true;
    } on DioException catch (e) {
      final d = e.response?.data;
      if (d is Map<String, dynamic> && d['message'] != null) {
        _error = d['message'].toString();
      } else {
        _error = "Erreur reproduction";
      }
      return false;
    } catch (e) {
      _error = e.toString();
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