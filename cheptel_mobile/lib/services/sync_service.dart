
import 'package:sqflite/sqflite.dart';

import '../data/datasources/local/local_database.dart';
import '../data/datasources/remote/api_client.dart';
import '../data/models/animal_model.dart';

class SyncService {
  final ApiClient _apiClient = ApiClient();

  Future<bool> isOnline() async {
    try {
      final response = await _apiClient.dio.get('/auth/health');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ===================================================
  // CACHE ANIMAUX
  // ===================================================

  Future<void> cacheAnimal(AnimalModel animal) async {
    final db = await LocalDatabase.database;

    await db.insert(
      'cached_animals',
      {
        'id': animal.id,
        'rfid_tag': animal.rfidTag,
        'species': animal.species,
        'breed': animal.breed,
        'gender': animal.gender,
        'weight': animal.weight,
        'status': animal.status,
        'color': animal.color,
        'birth_date': animal.birthDate,
        'farm_id': animal.farmId,
        'farm_name': animal.farmName,
        'last_synced': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<AnimalModel?> getAnimalFromCache(String rfidTag) async {
    final db = await LocalDatabase.database;

    final result = await db.query(
      'cached_animals',
      where: 'rfid_tag = ?',
      whereArgs: [rfidTag],
      limit: 1,
    );

    if (result.isEmpty) return null;

    final row = result.first;

    return AnimalModel(
      id: _toInt(row['id']),
      rfidTag: row['rfid_tag']?.toString() ?? '',
      species: row['species']?.toString() ?? '',
      breed: row['breed']?.toString(),
      gender: row['gender']?.toString(),
      weight: _toDouble(row['weight']),
      status: row['status']?.toString() ?? '',
      color: row['color']?.toString(),
      birthDate: row['birth_date']?.toString(),
      farmId: _toInt(row['farm_id']),
      farmName: row['farm_name']?.toString() ?? '',
    );
  }

  // ===================================================
  // CONSTATS OFFLINE
  // ===================================================

  Future<void> saveConstatOffline({
    required int farmId,
    int? controlSessionId,
    required String type,
    required String description,
    double? latitude,
    double? longitude,
    String? photoPath,
  }) async {
    final db = await LocalDatabase.database;

    await db.insert('cached_constats', {
      'farm_id': farmId,
      'control_session_id': controlSessionId,
      'type': type,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'photo_path': photoPath,
      'created_at': DateTime.now().toIso8601String(),
      'synced': 0,
    });
  }

  Future<int> syncConstats() async {
    final db = await LocalDatabase.database;
    int syncedCount = 0;

    final pending = await db.query(
      'cached_constats',
      where: 'synced = 0',
    );

    for (final row in pending) {
      try {
        await _apiClient.dio.post(
          '/constats',
          data: {
            'farmId': row['farm_id'],
            'controlSessionId': row['control_session_id'],
            'type': row['type'],
            'description': row['description'],
            'latitude': row['latitude'],
            'longitude': row['longitude'],
          },
        );

        await db.update(
          'cached_constats',
          {'synced': 1},
          where: 'id = ?',
          whereArgs: [row['id']],
        );

        syncedCount++;
      } catch (_) {}
    }

    return syncedCount;
  }

  // ===================================================
  // MOUVEMENTS OFFLINE
  // ===================================================

  Future<void> saveMovementOffline(Map<String, dynamic> data) async {
    final db = await LocalDatabase.database;

    await db.insert('cached_movements', {
      'animal_id': data['animalId'],
      'movement_type': data['movementType'],
      'from_farm_id': data['fromFarmId'],
      'to_farm_id': data['toFarmId'],
      'movement_date': data['movementDate'],
      'price': data['price'],
      'counterparty_name': data['counterpartyName'],
      'counterparty_phone': data['counterpartyPhone'],
      'document_reference': data['documentReference'],
      'latitude': data['latitude'],
      'longitude': data['longitude'],
      'notes': data['notes'],
      'synced': 0,
    });
  }

  Future<int> syncMovements() async {
    final db = await LocalDatabase.database;
    int syncedCount = 0;

    final pending = await db.query(
      'cached_movements',
      where: 'synced = 0',
    );

    for (final row in pending) {
      try {
        await _apiClient.dio.post(
          '/movements',
          data: {
            'animalId': row['animal_id'],
            'movementType': row['movement_type'],
            'fromFarmId': row['from_farm_id'],
            'toFarmId': row['to_farm_id'],
            'movementDate': row['movement_date'],
            'price': row['price'],
            'counterpartyName': row['counterparty_name'],
            'counterpartyPhone': row['counterparty_phone'],
            'documentReference': row['document_reference'],
            'latitude': row['latitude'],
            'longitude': row['longitude'],
            'notes': row['notes'],
          },
        );

        await db.update(
          'cached_movements',
          {'synced': 1},
          where: 'id = ?',
          whereArgs: [row['id']],
        );

        syncedCount++;
      } catch (_) {}
    }

    return syncedCount;
  }

  // ===================================================
  // REPRODUCTIONS OFFLINE
  // ===================================================

  Future<void> saveReproductionOffline(Map<String, dynamic> data) async {
    final db = await LocalDatabase.database;

    await db.insert('cached_reproductions', {
      'female_id': data['femaleId'],
      'male_id': data['maleId'],
      'breeding_date': data['breedingDate'],
      'expected_birth_date': data['expectedBirthDate'],
      'actual_birth_date': data['actualBirthDate'],
      'offspring_count': data['offspringCount'],
      'status': data['status'],
      'notes': data['notes'],
      'synced': 0,
    });
  }

  Future<int> syncReproductions() async {
    final db = await LocalDatabase.database;
    int syncedCount = 0;

    final pending = await db.query(
      'cached_reproductions',
      where: 'synced = 0',
    );

    for (final row in pending) {
      try {
        await _apiClient.dio.post(
          '/reproductions',
          data: {
            'femaleId': row['female_id'],
            'maleId': row['male_id'],
            'breedingDate': row['breeding_date'],
            'expectedBirthDate': row['expected_birth_date'],
            'actualBirthDate': row['actual_birth_date'],
            'offspringCount': row['offspring_count'],
            'status': row['status'],
            'notes': row['notes'],
          },
        );

        await db.update(
          'cached_reproductions',
          {'synced': 1},
          where: 'id = ?',
          whereArgs: [row['id']],
        );

        syncedCount++;
      } catch (_) {}
    }

    return syncedCount;
  }

  // ===================================================
  // SYNCHRO GLOBALE
  // ===================================================

  Future<Map<String, dynamic>> performFullSync() async {
    final online = await isOnline();

    if (!online) {
      return {
        'success': false,
        'message': 'Aucune connexion internet',
      };
    }

    int syncedConstats = await syncConstats();
    int syncedMovements = await syncMovements();
    int syncedReproductions = await syncReproductions();

    int total = syncedConstats + syncedMovements + syncedReproductions;

    return {
      'success': true,
      'syncedConstats': syncedConstats,
      'syncedMovements': syncedMovements,
      'syncedReproductions': syncedReproductions,
      'message': 'Synchronisation terminée. $total élément(s) envoyé(s).',
    };
  }

  // ===================================================
  // UTILITAIRES
  // ===================================================

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}