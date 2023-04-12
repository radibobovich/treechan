import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:treechan/screens/tab_navigator.dart';

class DrawerTabHistory extends DrawerTab {
  DrawerTabHistory(
      {required super.type,
      super.id,
      required super.name,
      required super.tag,
      required this.timestamp});

  final DateTime timestamp;
  late DatabaseFactory databaseFactory;
  DrawerTab toDrawerTab() {
    return DrawerTab(
        type: type, id: id, name: name, tag: tag, prevTab: prevTab);
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString(),
      'name': name,
      'tag': tag,
      'threadId': id,
      'timestamp': DateTime.now().toString()
    };
  }

  @override
  String toString() {
    return 'DrawerTab{type: ${type.toString()}, tag: $tag, id: $id, name: $name}';
  }
}

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
    if (Platform.isWindows || Platform.isLinux) {
      databaseFactory = databaseFactoryFfi;
      return databaseFactory.openDatabase(
        join(await getDatabasesPath(), 'history_database.db'),
        options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) {
              return db.execute(
                  'CREATE TABLE history(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, type TEXT, tag TEXT, threadId INTEGER, timestamp TEXT, name TEXT)');
            }),
      );
    } else if (Platform.isAndroid || Platform.isIOS) {
      return openDatabase(
        join(await getDatabasesPath(), 'history_database.db'),
        onCreate: (db, version) {
          return db.execute(
              'CREATE TABLE history(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, type TEXT, tag TEXT, threadId INTEGER, timestamp TEXT, name TEXT)');
        },
        version: 1,
      );
    } else {
      throw Exception("Unsupported platform");
    }
  }

  Future<void> add(DrawerTabHistory tab) async {
    if (tab.type != TabTypes.thread) {
      return;
    }
    final Database db = await _database;

    await db.insert('history', tab.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> remove(DrawerTabHistory tab) async {
    final Database db = await _database;

    await db.delete('history',
        where: 'type = ? AND tag = ? AND threadId = ?',
        whereArgs: [tab.type.toString(), tab.tag, tab.id]);
  }

  Future<void> removeMultiple(List<DrawerTabHistory> tabs) async {
    final Database db = await _database;

    for (DrawerTabHistory tab in tabs) {
      await db.delete('history',
          where: 'type = ? AND tag = ? AND threadId = ?',
          whereArgs: [tab.type.toString(), tab.tag, tab.id]);
    }
  }

  Future<List<DrawerTabHistory>> getHistory() async {
    final Database db = await _database;

    final List<Map<String, dynamic>> maps = await db.query('history');

    return List.generate(maps.length, (i) {
      final map = maps[i];
      TabTypes type = TabTypes.values
          .firstWhere((element) => element.toString() == map['type']);

      return DrawerTabHistory(
          type: type,
          tag: map['tag'],
          id: map['threadId'],
          name: map['name'],
          timestamp: DateTime.parse(map['timestamp']));
    }).reversed.toList();
  }
}
