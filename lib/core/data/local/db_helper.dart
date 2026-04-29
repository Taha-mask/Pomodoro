import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DbHelper {
  static final DbHelper _i = DbHelper._();
  factory DbHelper() => _i;
  DbHelper._();

  Database? _db;

  static void initFfi() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get _database async => _db ??= await _open();

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'pomodoro.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE settings (
            key   TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE pomodoros (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            task         TEXT,
            phase        TEXT NOT NULL,
            duration_min INTEGER NOT NULL,
            completed_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await _database;
    final rows = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await _database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> addPomodoro({
    String? task,
    required String phase,
    required int durationMin,
  }) async {
    final db = await _database;
    await db.insert('pomodoros', {
      'task': (task == null || task.trim().isEmpty) ? null : task.trim(),
      'phase': phase,
      'duration_min': durationMin,
      'completed_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<PomodoroRecord>> getRecent({int limit = 30}) async {
    final db = await _database;
    final rows = await db.query(
      'pomodoros',
      orderBy: 'completed_at DESC',
      limit: limit,
    );
    return rows.map(PomodoroRecord.fromMap).toList();
  }

  Future<void> clearHistory() async {
    final db = await _database;
    await db.delete('pomodoros');
  }
}

class PomodoroRecord {
  final int id;
  final String? task;
  final String phase;
  final int durationMin;
  final DateTime completedAt;

  const PomodoroRecord({
    required this.id,
    this.task,
    required this.phase,
    required this.durationMin,
    required this.completedAt,
  });

  factory PomodoroRecord.fromMap(Map<String, dynamic> m) => PomodoroRecord(
        id: m['id'] as int,
        task: m['task'] as String?,
        phase: m['phase'] as String,
        durationMin: m['duration_min'] as int,
        completedAt: DateTime.parse(m['completed_at'] as String),
      );

  bool get isWork => phase == 'work';
}
