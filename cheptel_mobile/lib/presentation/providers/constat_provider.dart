import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

import '../../data/datasources/remote/api_client.dart';
import '../../services/file_upload_service.dart';
import '../../services/sync_service.dart';

class ConstatProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final ImagePicker _picker = ImagePicker();
  final FileUploadService _uploadService = FileUploadService();
  final SyncService _syncService = SyncService();

  bool _isLoading = false;
  String? _error;
  String? _success;

  String _type = "MANQUANT";
  String _description = "";
  double? _latitude;
  double? _longitude;
  String? _localPhotoPath;
  String? _photoUrl;
  final List<File> _attachments = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get success => _success;
  String get type => _type;
  String get description => _description;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get hasPhoto => _localPhotoPath != null || _attachments.isNotEmpty;
  List<File> get attachments => List.unmodifiable(_attachments);
  int get attachmentCount => _attachments.length;
  bool get hasEnoughAttachments => _attachments.length >= 2;

  void setType(String newType) {
    _type = newType;
    notifyListeners();
  }

  void setDescription(String text) {
    _description = text;
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitude = position.latitude;
      _longitude = position.longitude;
    } catch (e) {
      debugPrint('GPS erreur : $e');
    }
    notifyListeners();
  }

  Future<void> pickPhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo != null) {
      _localPhotoPath = photo.path;
      _attachments.add(File(photo.path));
      notifyListeners();
    }
  }

  Future<void> pickPhotoFromGallery() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (photo != null) {
      _attachments.add(File(photo.path));
      notifyListeners();
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      _attachments.add(File(result.files.single.path!));
      notifyListeners();
    }
  }

  void removeAttachment(int index) {
    if (index >= 0 && index < _attachments.length) {
      _attachments.removeAt(index);
      notifyListeners();
    }
  }

  void removePhoto() {
    _localPhotoPath = null;
    _photoUrl = null;
    notifyListeners();
  }

  Future<bool> submitConstat(
      int farmId, {
        int? controlSessionId,
      }) async {
    if (_description.trim().isEmpty) {
      _error = "Veuillez ajouter une description";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    _success = null;
    notifyListeners();

    try {
      // Upload les pièces jointes si présentes
      List<String> uploadedUrls = [];

      for (final file in _attachments) {
        try {
          final url = await _uploadService.uploadPhoto(file.path);
          if (url != null && url.isNotEmpty) {
            uploadedUrls.add(url);
          }
        } catch (e) {
          debugPrint("Erreur upload fichier : $e");
        }
      }

      // Construire le payload
      final Map<String, dynamic> payload = {
        "farmId": farmId,
        "type": _type,
        "description": _description.trim(),
      };

      if (controlSessionId != null) {
        payload["controlSessionId"] = controlSessionId;
      }

      if (_latitude != null) {
        payload["latitude"] = _latitude;
      }

      if (_longitude != null) {
        payload["longitude"] = _longitude;
      }

      if (_latitude != null && _longitude != null) {
        payload["localisationText"] =
        "${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}";
      }

      if (uploadedUrls.isNotEmpty) {
        payload["photoUrl"] = uploadedUrls.first;
        payload["attachmentsJson"] = jsonEncode(uploadedUrls);
      }

      debugPrint("=== ENVOI CONSTAT ===");
      debugPrint("URL : /constats");
      debugPrint("Payload : $payload");

      // Envoi direct sans vérification isOnline
      final response = await _apiClient.dio.post(
        '/constats',
        data: payload,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      debugPrint("Status : ${response.statusCode}");
      debugPrint("Réponse : ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _success = "Constat envoyé avec succès";
        return true;
      } else {
        _error = "Erreur serveur : ${response.statusCode}";
        return false;
      }
    } on DioException catch (e) {
      debugPrint("DioException type : ${e.type}");
      debugPrint("DioException message : ${e.message}");
      debugPrint("DioException response : ${e.response?.data}");

      // Réseau vraiment indisponible → sauvegarder offline
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        debugPrint("Réseau indisponible → sauvegarde offline");

        try {
          await _syncService.saveConstatOffline(
            farmId: farmId,
            controlSessionId: controlSessionId,
            type: _type,
            description: _description.trim(),
            latitude: _latitude,
            longitude: _longitude,
            photoPath: _localPhotoPath,
          );
          _success = "Pas de connexion. Constat sauvegardé localement.";
          return true;
        } catch (offlineErr) {
          _error = "Erreur réseau et impossible de sauvegarder localement.";
          return false;
        }
      }

      // Erreur serveur (400, 403, 500...)
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        _error = data['message'].toString();
      } else if (data is String && data.isNotEmpty) {
        _error = data;
      } else {
        _error = "Erreur ${e.response?.statusCode ?? 'inconnue'}";
      }

      return false;
    } catch (e) {
      debugPrint("Erreur inattendue : $e");
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _isLoading = false;
    _error = null;
    _success = null;
    _type = "MANQUANT";
    _description = "";
    _latitude = null;
    _longitude = null;
    _localPhotoPath = null;
    _photoUrl = null;
    _attachments.clear();
    notifyListeners();
  }

  void clearMessages() {
    _error = null;
    _success = null;
    notifyListeners();
  }
}