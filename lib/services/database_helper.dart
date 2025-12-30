import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/plan_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'butterfly_plans.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE plans(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        subtitle TEXT,
        progress REAL,
        iconName TEXT,
        colorValue INTEGER,
        planType TEXT,
        thighCircumference REAL,
        calfCircumference REAL,
        isThighClosed INTEGER,
        isCalfClosed INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE plans ADD COLUMN planType TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE plans ADD COLUMN thighCircumference REAL');
      await db.execute('ALTER TABLE plans ADD COLUMN calfCircumference REAL');
      await db.execute('ALTER TABLE plans ADD COLUMN isThighClosed INTEGER');
      await db.execute('ALTER TABLE plans ADD COLUMN isCalfClosed INTEGER');
    }
  }

  Future<int> insertPlan(Plan plan) async {
    Database db = await database;
    return await db.insert('plans', plan.toMap());
  }

  Future<List<Plan>> getPlans() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('plans', orderBy: 'id DESC');
    return List.generate(maps.length, (i) {
      return Plan.fromMap(maps[i]);
    });
  }

  Future<int> updatePlan(Plan plan) async {
    Database db = await database;
    return await db.update(
      'plans',
      plan.toMap(),
      where: 'id = ?',
      whereArgs: [plan.id],
    );
  }

  Future<int> deletePlan(int id) async {
    Database db = await database;
    return await db.delete(
      'plans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
