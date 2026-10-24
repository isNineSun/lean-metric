import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/preset_exercise_model.dart';
import '../models/preset_food_model.dart';
import '../models/record_model.dart';

class RecordRepository {
  static final RecordRepository instance = RecordRepository._init();
  static Database? _database;

  RecordRepository._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lean_metric.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        weight REAL,
        isFasting INTEGER NOT NULL,
        sleepStart TEXT,
        sleepEnd TEXT,
        sleepDurationMinutes INTEGER,
        steps INTEGER,
        breakfast TEXT NOT NULL,
        lunch TEXT NOT NULL,
        dinner TEXT NOT NULL,
        otherFood TEXT NOT NULL,
        exercise TEXT NOT NULL,
        status TEXT NOT NULL,
        specialCases TEXT NOT NULL,
        specialNote TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE preset_foods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE preset_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        capacity TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS preset_foods (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS preset_exercises (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          capacity TEXT NOT NULL,
          type TEXT NOT NULL
        )
      ''');
    }
  }

  // =========================
  // 减脂记录 (Records)
  // =========================

  Future<Record> insertRecord(Record record) async {
    final db = await database;
    final id = await db.insert('records', record.toMap());
    return record.copyWith(id: id);
  }

  Future<List<Record>> getAllRecords() async {
    final db = await database;
    final maps = await db.query('records', orderBy: 'date DESC');
    return maps.map((map) => Record.fromMap(map)).toList();
  }

  Future<int> updateRecord(Record record) async {
    final db = await database;
    return await db.update(
      'records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteRecord(int id) async {
    final db = await database;
    return await db.delete(
      'records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // 预设饮食词条 (Preset Foods)
  // =========================

  Future<PresetFood> insertPresetFood(PresetFood food) async {
    final db = await database;
    final id = await db.insert('preset_foods', food.toMap());
    return food.copyWith(id: id);
  }

  Future<List<PresetFood>> getAllPresetFoods() async {
    final db = await database;
    final maps = await db.query('preset_foods', orderBy: 'id DESC');
    return maps.map((map) => PresetFood.fromMap(map)).toList();
  }

  Future<int> updatePresetFood(PresetFood food) async {
    final db = await database;
    return await db.update(
      'preset_foods',
      food.toMap(),
      where: 'id = ?',
      whereArgs: [food.id],
    );
  }

  Future<int> deletePresetFood(int id) async {
    final db = await database;
    return await db.delete(
      'preset_foods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // 训练预设/词条 (Preset Exercises)
  // =========================

  Future<PresetExercise> insertPresetExercise(PresetExercise exercise) async {
    final db = await database;
    final id = await db.insert('preset_exercises', exercise.toMap());
    return exercise.copyWith(id: id);
  }

  Future<List<PresetExercise>> getAllPresetExercises() async {
    final db = await database;
    final maps = await db.query('preset_exercises', orderBy: 'id DESC');
    return maps.map((map) => PresetExercise.fromMap(map)).toList();
  }

  Future<int> updatePresetExercise(PresetExercise exercise) async {
    final db = await database;
    return await db.update(
      'preset_exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<int> deletePresetExercise(int id) async {
    final db = await database;
    return await db.delete(
      'preset_exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // 缓存与清理
  // =========================

  Future<double> getDatabaseSizeInMB() async {
    final records = await getAllRecords();
    if (records.isEmpty) {
      return 0.0;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'lean_metric.db');
    final file = File(path);
    if (await file.exists()) {
      final bytes = await file.length();
      return bytes / (1024 * 1024);
    }
    return 0.0;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('records');
    await db.execute('VACUUM');
  }
}
