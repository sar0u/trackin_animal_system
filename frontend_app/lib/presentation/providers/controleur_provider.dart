import 'package:flutter/material.dart';

import '../../data/models/control_check_response.dart';
import '../../data/models/farm_model.dart';
import '../../data/repositories/controleur_repository.dart';
import '../../data/repositories/farm_repossitory.dart';


class ControleurProvider with ChangeNotifier {
  final ControleurRepository _controleurRepository = ControleurRepository();
  final FarmRepository _farmRepository = FarmRepository();

  bool _isLoading = false;
  bool _isLoadingFarms = false;
  String? _error;
  String? _success;

  List<FarmModel> _farms = [];
  FarmModel? _selectedFarm;

  final List<String> _scannedTags = [];
  ControlCheckResponse? _checkResult;

  bool get isLoading => _isLoading;
  bool get isLoadingFarms => _isLoadingFarms;
  String? get error => _error;
  String? get success => _success;

  List<FarmModel> get farms => _farms;
  FarmModel? get selectedFarm => _selectedFarm;

  List<String> get scannedTags => List.unmodifiable(_scannedTags);
  int get detectedCount => _scannedTags.length;

  ControlCheckResponse? get checkResult => _checkResult;

  Future<void> loadFarms() async {
    _isLoadingFarms = true;
    _error = null;
    notifyListeners();

    try {
      _farms = await _farmRepository.getFarms();

      if (_farms.isEmpty) {
        _error = "Aucune ferme disponible dans la base de données.";
      }
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoadingFarms = false;
      notifyListeners();
    }
  }

  void selectFarm(FarmModel farm) {
    _selectedFarm = farm;
    _checkResult = null;
    _success = "Ferme sélectionnée : ${farm.name}";
    _error = null;
    notifyListeners();
  }

  void addScannedTags(List<String> tags) {
    for (final tag in tags) {
      final clean = tag.trim();
      if (clean.isNotEmpty && !_scannedTags.contains(clean)) {
        _scannedTags.add(clean);
      }
    }

    _checkResult = null;
    _error = null;
    _success = "${tags.length} tag(s) ajouté(s)";
    notifyListeners();
  }

  void addManualTag(String tag) {
    final clean = tag.trim();

    if (clean.isEmpty) {
      _error = "Tag vide";
      notifyListeners();
      return;
    }

    if (!_scannedTags.contains(clean)) {
      _scannedTags.add(clean);
    }

    _checkResult = null;
    _error = null;
    _success = "Tag ajouté";
    notifyListeners();
  }

  void removeTag(String tag) {
    _scannedTags.remove(tag);
    _checkResult = null;
    notifyListeners();
  }

  Future<void> performCheck() async {
    if (_selectedFarm == null) {
      _error = "Veuillez sélectionner une ferme.";
      notifyListeners();
      return;
    }

    if (_scannedTags.isEmpty) {
      _error = "Veuillez scanner au moins un animal.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _success = null;
    _checkResult = null;
    notifyListeners();

    try {
      _checkResult = await _controleurRepository.checkEffectif(
        _selectedFarm!.id,
        _scannedTags,
      );
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetScan() {
    _scannedTags.clear();
    _checkResult = null;
    _success = null;
    _error = null;
    notifyListeners();
  }

  void resetAll() {
    _selectedFarm = null;
    _scannedTags.clear();
    _checkResult = null;
    _success = null;
    _error = null;
    notifyListeners();
  }
}