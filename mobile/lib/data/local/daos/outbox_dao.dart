import 'package:sqflite/sqflite.dart';
import '../database.dart';

/// DAO for managing pending sync requests
class OutboxDao {
  final AppDatabase _database;

  OutboxDao(this._database);

  /// Insert a new pending request
  Future<void> insertRequest({
    required String id,
    required String url,
    required String method,
    required String body,
    required int timestamp,
  }) async {
    final db = await _database.database;
    await db.insert(
      'pending_sync_requests',
      {
        'id': id,
        'url': url,
        'method': method,
        'body': body,
        'timestamp': timestamp,
        'retry_count': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all pending requests ordered by timestamp
  Future<List<Map<String, dynamic>>> getPendingRequests() async {
    final db = await _database.database;
    return await db.query(
      'pending_sync_requests',
      orderBy: 'timestamp ASC',
    );
  }

  /// Delete a request after successful sync
  Future<void> deleteRequest(String id) async {
    final db = await _database.database;
    await db.delete(
      'pending_sync_requests',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Increment retry count for a request
  Future<void> incrementRetryCount(String id) async {
    final db = await _database.database;
    await db.rawUpdate(
      'UPDATE pending_sync_requests SET retry_count = retry_count + 1 WHERE id = ?',
      [id],
    );
  }

  /// Get pending count
  Future<int> getPendingCount() async {
    final db = await _database.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM pending_sync_requests');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
