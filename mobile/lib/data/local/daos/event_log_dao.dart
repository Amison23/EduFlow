import '../database.dart';

/// Data Access Object for event logging
class EventLogDao {
  final Database _database;

  EventLogDao(this._database);

  /// Log an event
  Future<void> logEvent({
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

  /// Get events by type
  Future<List<Map<String, dynamic>>> getEventsByType(String eventType) async {
    final db = await _database.database;
    return db.query(
      'local_progress',
      where: 'event_type = ?',
      whereArgs: [eventType],
      orderBy: 'device_ts DESC',
    );
  }

  /// Get recent events
  Future<List<Map<String, dynamic>>> getRecentEvents({int limit = 50}) async {
    final db = await _database.database;
    return db.query(
      'local_progress',
      orderBy: 'device_ts DESC',
      limit: limit,
    );
  }

  /// Get events within a date range
  Future<List<Map<String, dynamic>>> getEventsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _database.database;
    return db.query(
      'local_progress',
      where: 'device_ts >= ? AND device_ts <= ?',
      whereArgs: [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: 'device_ts DESC',
    );
  }
}
