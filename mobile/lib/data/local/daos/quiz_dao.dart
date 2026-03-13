import 'dart:convert';
import 'package:sqflite/sqflite.dart' as sqlite;
import '../database.dart';

/// Data Access Object for quiz questions
class QuizDao {
  final AppDatabase _database;

  QuizDao(this._database);

  /// Insert or update a quiz question
  Future<void> upsertQuiz(Map<String, dynamic> quiz) async {
    final db = await _database.database;
    await db.insert(
      'local_quizzes',
      {
        'id': quiz['id'],
        'lesson_id': quiz['lesson_id'],
        'question': quiz['question'],
        'options': jsonEncode(quiz['options']),
        'correct_index': quiz['correct_index'],
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
  }

  /// Get quiz questions for a lesson
  Future<List<Map<String, dynamic>>> getQuizzesForLesson(String lessonId) async {
    final db = await _database.database;
    final results = await db.query(
      'local_quizzes',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
      orderBy: 'cached_at ASC',
    );

    return results.map((row) {
      final map = Map<String, dynamic>.from(row);
      if (map['options'] != null) {
        map['options'] = jsonDecode(map['options'] as String);
      }
      return map;
    }).toList();
  }

  /// Clear all quizzes
  Future<void> clearAll() async {
    final db = await _database.database;
    await db.delete('local_quizzes');
  }
}
