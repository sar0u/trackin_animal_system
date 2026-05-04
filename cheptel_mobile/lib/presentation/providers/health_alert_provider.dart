import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../data/datasources/remote/api_client.dart';
import '../../data/models/health_alert_model.dart';

class HealthAlertProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  String? _error;
  List<HealthAlertModel> _alerts = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<HealthAlertModel> get alerts => _alerts;

  Future<void> loadAlerts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/alerts');
      final list = response.data as List;
      _alerts = list
          .map((e) => HealthAlertModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        _error = data['message'].toString();
      } else {
        _error = "Erreur chargement alertes";
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateAndLoad() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiClient.dio.post('/alerts/generate');
      await loadAlerts();
    } catch (e) {
      await loadAlerts();
    }
  }

  Future<void> resolveAlert(int id) async {
    try {
      await _apiClient.dio.put('/alerts/$id/resolve');
      await loadAlerts();
    } catch (e) {
      _error = "Impossible de résoudre l'alerte";
      notifyListeners();
    }
  }
}