import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class HiddenThreadsDatabase {
  static final HiddenThreadsDatabase _instance =
      HiddenThreadsDatabase._internal();
  factory HiddenThreadsDatabase() {
    return _instance;
  }

  late Future<Database> _database;

  HiddenThreadsDatabase._internal() {
    _database = _createDatabase();
  }

  Future<Database> _createDatabase() async {
    const String sql =
        'CREATE TABLE initial(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL)';
    if (Platform.isWindows || Platform.isLinux) {
      databaseFactory = databaseFactoryFfi;
      return databaseFactory.openDatabase(
        join(await getDatabasesPath(), 'hidden_threads_database.db'),
        options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) {
              return db.execute(sql);
            }),
      );
    } else if (Platform.isAndroid || Platform.isIOS) {
      return openDatabase(
        join(await getDatabasesPath(), 'hidden_threads_database.db'),
        onCreate: (db, version) {
          return db.execute(sql);
        },
        version: 1,
      );
    } else {
      throw Exception("Unsupported platform");
    }
  }

  Future<void> _createBoardTable(String tag) async {
    final Database db = await _database;

    final String sql =
        'CREATE TABLE $tag(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, threadId INTEGER, name TEXT, timestamp INTEGER)';
    await db.execute(sql);
  }

  Future<void> removeBoardTable(String tag) async {
    final Database db = await _database;

    await db.execute('DROP TABLE IF EXISTS $tag');
  }

  Future<void> removeAllTables() async {
    final Database db = await _database;

    List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");

    for (var table in tables) {
      String tableName = table['name'] as String;
      await db.delete(tableName);
    }
  }

  Future<void> addThread(String tag, int threadId, String name) async {
    final Database db = await _database;

    if (!await _tableExists(tag)) {
      await _createBoardTable(tag);
    }

    /// check if already has in database
    final occurence = await db.query(
      tag,
      where: 'threadId = ?',
      whereArgs: [threadId],
      limit: 1,
    );
    if (occurence.isNotEmpty) {
      return;
    }

    await db.insert(tag, {
      'threadId': threadId,
      'name': name,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> removeThread(String tag, int threadId) async {
    final Database db = await _database;
    if (!await _tableExists(tag)) return;

    await db.delete(tag, where: 'threadId = ?', whereArgs: [threadId]);
  }

  Future<List<int>> getHiddenThreadIds(String tag) async {
    final Database db = await _database;
    if (!await _tableExists(tag)) {
      return [];
    }
    final items = await db.rawQuery('SELECT threadId FROM $tag');
    List<int> hiddenThreads =
        items.map((item) => item['threadId'] as int).toList();
    return hiddenThreads;
  }

  Future<List<HiddenThread>> getHiddenThreads(String tag) async {
    final Database db = await _database;

    if (!await _tableExists(tag)) {
      return [];
    }
    final List<Map<String, dynamic>> maps = await db.query(tag);

    return List.generate(maps.length, (i) {
      final map = maps[i];

      return HiddenThread(
        name: map['name'],
        tag: tag,
        id: map['threadId'],
        timestamp: map['timestamp'],
      );
    });
  }

  Future<bool> _tableExists(String tag) async {
    final Database db = await _database;
    return (await db
            .query('sqlite_master', where: 'name = ?', whereArgs: [tag]))
        .isNotEmpty;
  }
}

class HiddenThread {
  String name;
  String tag;
  int id;
  int timestamp;
  HiddenThread({
    required this.name,
    required this.tag,
    required this.id,
    required this.timestamp,
  });
}
