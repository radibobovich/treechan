import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../domain/models/tab.dart';

class HistoryDatabase {
  static final HistoryDatabase _instance = HistoryDatabase._internal();
  factory HistoryDatabase() {
    return _instance;
  }

  late Future<Database> _database;
  HistoryDatabase._internal() {
    _database = _createDatabase();
  }

  Future<Database> _createDatabase() async {
    const String sql =
        'CREATE TABLE history(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, type TEXT, tag TEXT, threadId INTEGER, timestamp TEXT, name TEXT)';
    if (Platform.isWindows || Platform.isLinux) {
      databaseFactory = databaseFactoryFfi;
      return databaseFactory.openDatabase(
        join(await getDatabasesPath(), 'history_database.db'),
        options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) {
              return db.execute(sql);
            }),
      );
    } else if (Platform.isAndroid || Platform.isIOS) {
      return openDatabase(
        join(await getDatabasesPath(), 'history_database.db'),
        onCreate: (db, version) {
          return db.execute(sql);
        },
        version: 1,
      );
    } else {
      throw Exception("Unsupported platform");
    }
  }

  Future<void> add(DrawerTab tab) async {
    if (tab.name == null || tab is! ThreadTab) {
      return;
    }
    final Database db = await _database;

    await db.insert('history', tab.toHistoryTab().toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> remove(HistoryTab tab) async {
    final Database db = await _database;

    await db.delete('history',
        where: 'type = ? AND tag = ? AND threadId = ? AND timestamp = ?',
        whereArgs: [
          tab.tag,
          tab.id,
          tab.timestamp.toString(),
        ]);
  }

  Future<void> removeMultiple(List<HistoryTab> tabs) async {
    final Database db = await _database;

    for (HistoryTab tab in tabs) {
      await db.delete('history',
          where: 'type = ? AND tag = ? AND threadId = ? AND timestamp = ?',
          whereArgs: [
            tab.tag,
            tab.id,
            tab.timestamp.toString(),
          ]);
    }
  }

  Future<void> clear() async {
    final Database db = await _database;

    await db.delete('history');
  }

  Future<List<HistoryTab>> getHistory() async {
    final Database db = await _database;

    final List<Map<String, dynamic>> maps = await db.query('history');

    return List.generate(maps.length, (i) {
      final map = maps[i];

      return HistoryTab(
          tag: map['tag'],
          id: map['threadId'],
          name: map['name'],
          prevTab: boardListTab,
          timestamp: DateTime.parse(map['timestamp']));
    }).reversed.toList();
  }
}
