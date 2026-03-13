import 'package:sqflite/sqflite.dart' as sqlite;
import 'package:path/path.dart';

/// Local SQLite database for EduFlow
class AppDatabase {
  static sqlite.Database? _database;
  
  AppDatabase();

  /// Get database instance
  Future<sqlite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<sqlite.Database> _initDatabase() async {
    final dbPath = await sqlite.getDatabasesPath();
    final path = join(dbPath, 'eduflow.db');
    
    return await sqlite.openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _onCreate(sqlite.Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _createTables(sqlite.Database db) async {
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

    // Generic outbox for other API requests
    await db.execute('''
      CREATE TABLE pending_sync_requests (
        id TEXT PRIMARY KEY,
        url TEXT,
        method TEXT,
        body TEXT,
        timestamp INTEGER,
        retry_count INTEGER DEFAULT 0
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
    await db.execute('CREATE INDEX idx_pending_requests_ts ON pending_sync_requests(timestamp)');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(sqlite.Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pending_sync_requests (
          id TEXT PRIMARY KEY,
          url TEXT,
          method TEXT,
          body TEXT,
          timestamp INTEGER,
          retry_count INTEGER DEFAULT 0
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_pending_requests_ts ON pending_sync_requests(timestamp)');
    }
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
