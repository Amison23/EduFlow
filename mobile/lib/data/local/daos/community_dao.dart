import 'package:sqflite/sqflite.dart' as sqlite;
import '../database.dart';

/// Data Access Object for study groups
class CommunityDao {
  final AppDatabase _database;

  CommunityDao(this._database);

  /// Insert or update a study group
  Future<void> upsertGroup(Map<String, dynamic> group) async {
    final db = await _database.database;
    await db.insert(
      'local_groups',
      {
        'id': group['id'],
        'name': group['name'],
        'subject': group['subject'],
        'creator_id': group['creator_id'],
        'max_members': group['max_members'],
        'is_public': group['is_public'] == true ? 1 : 0,
        'member_count': group['group_members'] != null ? 
                         (group['group_members'] is List ? group['group_members'].length : (group['group_members']['count'] ?? 0)) : 0,
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
  }

  /// Get all cached study groups
  Future<List<Map<String, dynamic>>> getGroups({String? subject}) async {
    final db = await _database.database;
    if (subject != null) {
      return db.query(
        'local_groups',
        where: 'subject = ?',
        whereArgs: [subject],
        orderBy: 'cached_at DESC',
      );
    }
    return db.query('local_groups', orderBy: 'cached_at DESC');
  }

  /// Clear all groups
  Future<void> clearAll() async {
    final db = await _database.database;
    await db.delete('local_groups');
  }
}
