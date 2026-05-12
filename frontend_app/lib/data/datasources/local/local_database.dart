import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cheptel_local.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  static Future<void> _createDB(Database db, int version) async {
    // Cache animaux
    await db.execute('''
      CREATE TABLE cached_animals (
        id INTEGER PRIMARY KEY,
        rfid_tag TEXT UNIQUE NOT NULL,
        species TEXT NOT NULL,
        breed TEXT,
        gender TEXT,
        weight REAL,
        status TEXT NOT NULL,
        color TEXT,
        birth_date TEXT,
        farm_id INTEGER NOT NULL,
        farm_name TEXT NOT NULL,
        last_synced TEXT NOT NULL
      )
    ''');

    // Cache constats offline
    await db.execute('''
      CREATE TABLE cached_constats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        farm_id INTEGER NOT NULL,
        control_session_id INTEGER,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        photo_path TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Cache mouvements offline
    await db.execute('''
      CREATE TABLE cached_movements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id INTEGER NOT NULL,
        movement_type TEXT NOT NULL,
        from_farm_id INTEGER,
        to_farm_id INTEGER,
        movement_date TEXT NOT NULL,
        price REAL,
        counterparty_name TEXT,
        counterparty_phone TEXT,
        document_reference TEXT,
        latitude REAL,
        longitude REAL,
        notes TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Cache reproduction offline
    await db.execute('''
      CREATE TABLE cached_reproductions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        female_id INTEGER NOT NULL,
        male_id INTEGER,
        breeding_date TEXT NOT NULL,
        expected_birth_date TEXT,
        actual_birth_date TEXT,
        offspring_count INTEGER,
        status TEXT,
        notes TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Cache alertes
    await db.execute('''
      CREATE TABLE cached_alerts (
        id INTEGER PRIMARY KEY,
        animal_id INTEGER NOT NULL,
        alert_type TEXT NOT NULL,
        message TEXT,
        due_date TEXT NOT NULL,
        is_resolved INTEGER DEFAULT 0,
        severity TEXT,
        last_synced TEXT NOT NULL
      )
    ''');
  }
}