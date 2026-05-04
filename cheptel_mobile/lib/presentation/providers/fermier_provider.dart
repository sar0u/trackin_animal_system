import 'package:flutter/material.dart';

import '../../data/datasources/remote/api_client.dart';
import '../../data/models/animal_model.dart';
import '../../data/models/farm_stats_model.dart';
import '../../data/repositories/animal_repository.dart';
import '../../services/nfc_service.dart';

class FermierProvider with ChangeNotifier {
  final AnimalRepository _animalRepository = AnimalRepository();
  final NfcService _nfcService = NfcService();
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  bool _isLoadingStats = false;
  bool _isLoadingMyAnimals = false;
  bool _isLoadingAlerts = false;

  String? _error;
  String? _success;

  AnimalModel? _animal;
  String? _lastScannedTag;

  FarmStatsModel? _stats;
  List<AnimalModel> _myAnimals = [];
  List<Map<String, dynamic>> _myAlerts = [];

  bool get isLoading => _isLoading;
  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingMyAnimals => _isLoadingMyAnimals;
  bool get isLoadingAlerts => _isLoadingAlerts;

  String? get error => _error;
  String? get success => _success;

  AnimalModel? get animal => _animal;
  String? get lastScannedTag => _lastScannedTag;

  FarmStatsModel? get stats => _stats;
  List<AnimalModel> get myAnimals => _myAnimals;
  List<Map<String, dynamic>> get myAlerts => _myAlerts;

  Future<void> loadStats() async {
    _isLoadingStats = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/fermier/stats');
      _stats = FarmStatsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint("Erreur stats : $e");
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  Future<void> loadMyAnimals() async {
    _isLoadingMyAnimals = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/fermier/animals');
      final list = response.data as List;
      _myAnimals = list
          .map((e) => AnimalModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = "Impossible de charger vos animaux";
      debugPrint("Erreur animaux : $e");
    } finally {
      _isLoadingMyAnimals = false;
      notifyListeners();
    }
  }

  Future<void> loadMyAlerts() async {
    _isLoadingAlerts = true;
    notifyListeners();

    try {
      // Générer les alertes d'abord
      await _apiClient.dio.post('/alerts/generate');

      // Puis charger les alertes de la ferme
      final response = await _apiClient.dio.get('/fermier/alerts');
      final list = response.data as List;
      _myAlerts = list.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint("Erreur alertes fermier : $e");
      _myAlerts = [];
    } finally {
      _isLoadingAlerts = false;
      notifyListeners();
    }
  }

  Future<void> searchAnimalByRfid(String rfidTag) async {
    if (rfidTag.trim().isEmpty) {
      _error = "Veuillez saisir un identifiant RFID";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _success = null;
    _animal = null;
    notifyListeners();

    try {
      _lastScannedTag = rfidTag.trim();
      _animal = await _animalRepository.getAnimalByRfid(rfidTag.trim());
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> scanNfcAndLoadAnimal() async {
    _isLoading = true;
    _error = null;
    _success = null;
    _animal = null;
    notifyListeners();

    try {
      final bool available = await _nfcService.isAvailable();

      if (!available) {
        _isLoading = false;
        notifyListeners();
        return "NFC_UNAVAILABLE";
      }

      final tagId = await _nfcService.scanTag();

      if (tagId == null || tagId.isEmpty) {
        _success = "Aucun tag détecté. Réessayez.";
        return null;
      }

      _lastScannedTag = tagId;
      _animal = await _animalRepository.getAnimalByRfid(tagId);

      return null;
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", "");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAnimalFromScan(String scannedCode) async {
    await searchAnimalByRfid(scannedCode);
  }

  Future<bool> createAnimal(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    _success = null;
    notifyListeners();

    try {
      _animal = await _animalRepository.createAnimal(data);
      _success = "Animal créé avec succès !";
      await loadMyAnimals();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", "");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAnimal(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    _success = null;
    notifyListeners();

    try {
      await _animalRepository.updateAnimal(id, data);
      _success = "Animal modifié avec succès !";
      await loadMyAnimals();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", "");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _animal = null;
    _error = null;
    _success = null;
    _lastScannedTag = null;
    notifyListeners();
  }
}