import 'package:flutter/material.dart';

import '../../data/models/farm_model.dart';
import '../../data/models/health_sheet_model.dart';
import '../../data/repositories/farm_repossitory.dart';
import '../../data/repositories/veterinaire_repository.dart';
import '../../services/nfc_service.dart';

class VeterinaireProvider with ChangeNotifier {
  final VeterinaireRepository _repo = VeterinaireRepository();
  final FarmRepository _farmRepo = FarmRepository();
  final NfcService _nfcService = NfcService();

  bool _isLoading = false;
  bool _isLoadingFarms = false;
  String? _error;
  String? _successMessage;
  HealthSheetModel? _healthSheet;
  String? _lastScannedTag;
  List<FarmModel> _farms = [];

  bool get isLoading => _isLoading;
  bool get isLoadingFarms => _isLoadingFarms;
  String? get error => _error;
  String? get successMessage => _successMessage;
  HealthSheetModel? get healthSheet => _healthSheet;
  String? get lastScannedTag => _lastScannedTag;
  List<FarmModel> get farms => _farms;

  // ===========================
  // RECHERCHE PAR RFID
  // ===========================

  Future<void> searchHealthSheet(String rfidTag) async {
    if (rfidTag.trim().isEmpty) {
      _error = "Veuillez saisir un identifiant RFID";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _successMessage = null;
    _healthSheet = null;
    notifyListeners();

    try {
      _lastScannedTag = rfidTag.trim();
      _healthSheet = await _repo.getHealthSheet(rfidTag.trim());
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================
  // SCAN NFC (ne plante plus)
  // ===========================

  Future<String?> scanAndLoadHealthSheet() async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    _healthSheet = null;
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
        _successMessage = "Aucun tag détecté. Réessayez.";
        return null;
      }

      _lastScannedTag = tagId;
      _healthSheet = await _repo.getHealthSheet(tagId);

      return null;
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", "");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================
  // AJOUTER VACCINATION
  // ===========================

  Future<bool> addVaccination(
      String rfidTag,
      Map<String, dynamic> data,
      ) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repo.addVaccination(rfidTag, data);
      _successMessage = "Vaccination enregistrée avec succès";
      await searchHealthSheet(rfidTag);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", "");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================
  // AJOUTER CONSULTATION
  // ===========================

  Future<bool> addHealthRecord(
      String rfidTag,
      Map<String, dynamic> data,
      ) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repo.addHealthRecord(rfidTag, data);
      _successMessage = "Consultation enregistrée avec succès";
      await searchHealthSheet(rfidTag);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", "");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================
  // FERMES DISPONIBLES
  // ===========================

  Future<void> loadFarms() async {
    _isLoadingFarms = true;
    notifyListeners();

    try {
      _farms = await _farmRepo.getFarms();
    } catch (e) {
      debugPrint("Erreur chargement fermes : $e");
      _farms = [];
    } finally {
      _isLoadingFarms = false;
      notifyListeners();
    }
  }

  // ===========================
  // RESET
  // ===========================

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  void clear() {
    _healthSheet = null;
    _lastScannedTag = null;
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}