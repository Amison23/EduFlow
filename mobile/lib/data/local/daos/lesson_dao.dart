import 'package:sqflite/sqflite.dart' as sqlite;
import '../database.dart';

/// Data Access Object for lessons
class LessonDao {
  final AppDatabase _database;

  LessonDao(this._database);

  /// Insert or update a lesson
  Future<void> upsertLesson({
    required String id,
    required String packId,
    required String title,
    required int sequence,
    required String content,
    String? audioPath,
  }) async {
    final db = await _database.database;
    await db.insert(
      'local_lessons',
      {
        'id': id,
        'pack_id': packId,
        'title': title,
        'sequence': sequence,
        'content': content,
        'audio_path': audioPath,
        'downloaded_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
  }

  /// Get a lesson by ID
  Future<Map<String, dynamic>?> getLesson(String id) async {
    final db = await _database.database;
    final results = await db.query(
      'local_lessons',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get all lessons for a pack
  Future<List<Map<String, dynamic>>> getLessonsForPack(String packId) async {
    final db = await _database.database;
    return db.query(
      'local_lessons',
      where: 'pack_id = ?',
      whereArgs: [packId],
      orderBy: 'sequence ASC',
    );
  }

  /// Get all downloaded lessons
  Future<List<Map<String, dynamic>>> getAllLessons() async {
    final db = await _database.database;
    return db.query('local_lessons', orderBy: 'sequence ASC');
  }

  /// Check if a pack has been downloaded
  Future<bool> isPackDownloaded(String packId) async {
    final db = await _database.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM local_lessons WHERE pack_id = ?',
      [packId],
    );
    return (result.first['count'] as int) > 0;
  }

  /// Delete lessons for a pack
  Future<void> deletePackLessons(String packId) async {
    final db = await _database.database;
    await db.delete(
      'local_lessons',
      where: 'pack_id = ?',
      whereArgs: [packId],
    );
  }

  /// Get downloaded pack IDs
  Future<List<String>> getDownloadedPackIds() async {
    final db = await _database.database;
    final results = await db.rawQuery(
      'SELECT DISTINCT pack_id FROM local_lessons',
    );
    return results.map((e) => e['pack_id'] as String).toList();
  }

  /// Clear all lessons
  Future<void> clearAll() async {
    final db = await _database.database;
    await db.delete('local_lessons');
  }
}
