import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Local SQLite database for EduFlow
class Database {
  static Database? _database;
  
  Database();

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'eduflow.db');
    
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    
    return _database!;
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Local lesson content
    await db.execute('''
      CREATE TABLE local_lessons (
        id TEXT PRIMARY KEY,
        pack_id TEXT,
        title TEXT,
        sequence INTEGER,
        content TEXT,
        audio_path TEXT,
        downloaded_at INTEGER
      )
    ''');

    // Progress events (append-only log)
    await db.execute('''
      CREATE TABLE local_progress (
        id TEXT PRIMARY KEY,
        lesson_id TEXT,
        event_type TEXT,
        score REAL,
        device_ts INTEGER,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Quiz weights for adaptive learning
    await db.execute('''
      CREATE TABLE quiz_weights (
        topic_id TEXT PRIMARY KEY,
        weight REAL DEFAULT 1.0,
        updated_at INTEGER
      )
    ''');

    // User preferences
    await db.execute('''
      CREATE TABLE user_preferences (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_progress_synced ON local_progress(synced)');
    await db.execute('CREATE INDEX idx_progress_lesson ON local_progress(lesson_id)');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future schema migrations here
  }

  /// Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Clear all data (for logout)
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('local_lessons');
    await db.delete('local_progress');
    await db.delete('quiz_weights');
    await db.delete('user_preferences');
  }
}
