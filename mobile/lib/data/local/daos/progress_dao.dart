import '../database.dart';

/// Data Access Object for progress events
class ProgressDao {
  final Database _database;

  ProgressDao(this._database);

  /// Insert a new progress event
  Future<void> insertProgress({
    required String id,
    required String lessonId,
    required String eventType,
    double? score,
    required int deviceTimestamp,
  }) async {
    final db = await _database.database;
    await db.insert('local_progress', {
      'id': id,
      'lesson_id': lessonId,
      'event_type': eventType,
      'score': score,
      'device_ts': deviceTimestamp,
      'synced': 0,
    });
  }

  /// Get all unsynced progress events
  Future<List<Map<String, dynamic>>> getUnsyncedEvents() async {
    final db = await _database.database;
    return db.query(
      'local_progress',
      where: 'synced = ?',
      whereArgs: [0],
      limit: 100,
    );
  }

  /// Mark events as synced
  Future<void> markAsSynced(List<String> ids) async {
    if (ids.isEmpty) return;
    
    final db = await _database.database;
    final placeholders = ids.map((_) => '?').join(',');
    await db.rawUpdate(
      'UPDATE local_progress SET synced = 1 WHERE id IN ($placeholders)',
      ids,
    );
  }

  /// Get count of unsynced events
  Future<int> getUnsyncedCount() async {
    final db = await _database.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM local_progress WHERE synced = 0',
    );
    return result.first['count'] as int;
  }

  /// Get all progress events for a lesson
  Future<List<Map<String, dynamic>>> getEventsForLesson(String lessonId) async {
    final db = await _database.database;
    return db.query(
      'local_progress',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
      orderBy: 'device_ts DESC',
    );
  }

  /// Get total progress events count
  Future<int> getTotalCount() async {
    final db = await _database.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM local_progress');
    return result.first['count'] as int;
  }

  /// Clear all progress data
  Future<void> clearAll() async {
    final db = await _database.database;
    await db.delete('local_progress');
  }
}
