import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:treechan/di/injection.dart';
import 'package:treechan/domain/models/tab.dart';
import 'package:treechan/utils/constants/enums.dart';

abstract class IHistoryDatabase {
  Future<void> add(DrawerTab tab);
  Future<void> remove(HistoryTab tab);
  Future<void> removeMultiple(List<HistoryTab> tabs);
  Future<void> clear();
  Future<List<HistoryTab>> getHistory();
}

@LazySingleton(as: IHistoryDatabase, env: [Env.test, Env.dev, Env.prod])
class HistoryDatabase implements IHistoryDatabase {
  late Future<Database> _database;

  HistoryDatabase() {
    _database = _createDatabase();
  }

  Future<Database> _createDatabase() async {
    const String sql =
        'CREATE TABLE history(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, imageboard TEXT, archiveDate TEXT, tag TEXT, threadId INTEGER, timestamp TEXT, name TEXT)';
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

  @override
  Future<void> add(DrawerTab tab) async {
    final prefs = await SharedPreferences.getInstance();
    final bool keepHistory = prefs.getBool('keepHistory') ?? true;
    if (tab.name == null || tab is! ThreadTab || !keepHistory) {
      return;
    }
    final Database db = await _database;

    await db.insert('history', tab.toHistoryTab().toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> remove(HistoryTab tab) async {
    final Database db = await _database;

    await db.delete('history',
        where: 'imageboard = ? AND tag = ? AND threadId = ? AND timestamp = ?',
        whereArgs: [
          tab.imageboard.name,
          tab.tag,
          tab.id,
          tab.timestamp.toString(),
        ]);
  }

  @override
  Future<void> removeMultiple(List<HistoryTab> tabs) async {
    final Database db = await _database;

    for (HistoryTab tab in tabs) {
      await db.delete('history',
          where:
              'imageboard = ? AND tag = ? AND threadId = ? AND timestamp = ?',
          whereArgs: [
            tab.imageboard.name,
            tab.tag,
            tab.id,
            tab.timestamp.toString(),
          ]);
    }
  }

  @override
  Future<void> clear() async {
    final Database db = await _database;

    await db.delete('history');
  }

  @override
  Future<List<HistoryTab>> getHistory() async {
    final Database db = await _database;

    final List<Map<String, dynamic>> maps = await db.query('history');

    return List.generate(maps.length, (i) {
      final map = maps[i];

      return HistoryTab(
          tag: map['tag'],
          id: map['threadId'],
          name: map['name'],
          imageboard: imageboardFromString(map['imageboard']),
          archiveDate: map['archiveDate'],
          prevTab: boardListTab,
          timestamp: DateTime.parse(map['timestamp']));
    }).reversed.toList();
  }
}
