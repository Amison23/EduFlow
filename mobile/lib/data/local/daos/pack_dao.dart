import 'package:sqflite/sqflite.dart' as sqlite;
import '../database.dart';

/// Data Access Object for lesson packs
class PackDao {
  final AppDatabase _database;

  PackDao(this._database);

  /// Insert or update a lesson pack
  Future<void> upsertPack(Map<String, dynamic> pack) async {
    final db = await _database.database;
    await db.insert(
      'local_packs',
      {
        ...pack,
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
  }

  /// Get all lesson packs
  Future<List<Map<String, dynamic>>> getAllPacks({String? language}) async {
    final db = await _database.database;
    if (language != null) {
      return db.query(
        'local_packs',
        where: 'language = ?',
        whereArgs: [language],
        orderBy: 'level ASC',
      );
    }
    return db.query('local_packs', orderBy: 'level ASC');
  }

  /// Clear all packs
  Future<void> clearAll() async {
    final db = await _database.database;
    await db.delete('local_packs');
  }
}
