import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('clinical_precision.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        clinical_identifier TEXT UNIQUE NOT NULL,
        role TEXT NOT NULL DEFAULT 'doctor',
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE patients (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        date_of_birth INTEGER NOT NULL,
        gender TEXT NOT NULL,
        phone TEXT NOT NULL,
        blood_group TEXT NOT NULL,
        primary_diagnosis TEXT NOT NULL DEFAULT '',
        status TEXT NOT NULL DEFAULT 'stable',
        created_by TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (created_by) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE visits (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        recorded_by TEXT NOT NULL,
        visit_date INTEGER NOT NULL,
        chief_complaint TEXT,
        diagnosis TEXT NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        heart_rate INTEGER NOT NULL,
        temperature REAL NOT NULL,
        blood_pressure TEXT NOT NULL,
        weight REAL NOT NULL DEFAULT 0,
        patient_status TEXT NOT NULL DEFAULT 'stable',
        FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE allergies (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        allergen_name TEXT NOT NULL,
        severity TEXT NOT NULL DEFAULT 'moderate',
        reaction_description TEXT,
        status TEXT NOT NULL DEFAULT 'active',
        recorded_by TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE medications (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        medication_name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        frequency TEXT NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER,
        status TEXT NOT NULL DEFAULT 'active',
        prescribed_by TEXT NOT NULL,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
