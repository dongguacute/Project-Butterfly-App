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
    print('Opening database at $path');
    return await openDatabase(
      path,
      version: 11,
      onCreate: (db, version) async {
        print('Creating database version $version');
        await _onCreate(db, version);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print('Upgrading database from $oldVersion to $newVersion');
        await _onUpgrade(db, oldVersion, newVersion);
      },
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
        isCalfClosed INTEGER,
        isThighHard INTEGER,
        isCalfHard INTEGER,
        isLegBoneStraight INTEGER,
        weight REAL,
        height REAL,
        reminderTime TEXT,
        currentDay INTEGER DEFAULT 1,
        targetLegShape TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 无论从哪个版本升级，都确保这些字段存在
    await _addColumnIfNotExists(db, 'plans', 'planType', 'TEXT');
    await _addColumnIfNotExists(db, 'plans', 'thighCircumference', 'REAL');
    await _addColumnIfNotExists(db, 'plans', 'calfCircumference', 'REAL');
    await _addColumnIfNotExists(db, 'plans', 'isThighClosed', 'INTEGER');
    await _addColumnIfNotExists(db, 'plans', 'isCalfClosed', 'INTEGER');
    await _addColumnIfNotExists(db, 'plans', 'isThighHard', 'INTEGER');
    await _addColumnIfNotExists(db, 'plans', 'isCalfHard', 'INTEGER');
    await _addColumnIfNotExists(db, 'plans', 'isLegBoneStraight', 'INTEGER');
    await _addColumnIfNotExists(db, 'plans', 'weight', 'REAL');
    await _addColumnIfNotExists(db, 'plans', 'height', 'REAL');
    await _addColumnIfNotExists(db, 'plans', 'reminderTime', 'TEXT');
    await _addColumnIfNotExists(db, 'plans', 'currentDay', 'INTEGER DEFAULT 1');
    await _addColumnIfNotExists(db, 'plans', 'targetLegShape', 'TEXT');
    print('Database upgrade completed');
  }

  Future<void> _addColumnIfNotExists(Database db, String tableName, String columnName, String columnType) async {
    try {
      // 检查列是否存在
      var tableInfo = await db.rawQuery('PRAGMA table_info($tableName)');
      bool exists = false;
      for (var column in tableInfo) {
        if (column['name'].toString().toLowerCase() == columnName.toLowerCase()) {
          exists = true;
          break;
        }
      }
      
      if (!exists) {
        print('Adding column $columnName to $tableName');
        await db.execute('ALTER TABLE $tableName ADD COLUMN $columnName $columnType');
      } else {
        print('Column $columnName already exists in $tableName');
      }
    } catch (e) {
      print('Error checking/adding column $columnName: $e');
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

  Future<Plan?> getPlanById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'plans',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Plan.fromMap(maps.first);
    }
    return null;
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
