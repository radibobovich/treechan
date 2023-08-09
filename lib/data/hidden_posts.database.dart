import 'dart:io';
import 'dart:math';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:treechan/utils/remove_html.dart';

class HiddenPostsDatabase {
  static final HiddenPostsDatabase _instance = HiddenPostsDatabase._internal();

  factory HiddenPostsDatabase() {
    return _instance;
  }

  late Future<Database> _database;

  HiddenPostsDatabase._internal() {
    _database = _createDatabase();
  }

  Future<Database> _createDatabase() async {
    const String sql =
        'CREATE TABLE initial(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL)';
    if (Platform.isWindows || Platform.isLinux) {
      databaseFactory = databaseFactoryFfi;
      return databaseFactory.openDatabase(
        join(await getDatabasesPath(), 'hidden_posts_database.db'),
        options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) {
              return db.execute(sql);
            }),
      );
    } else if (Platform.isAndroid || Platform.isIOS) {
      return openDatabase(
        join(await getDatabasesPath(), 'hidden_posts_database.db'),
        onCreate: (db, version) {
          return db.execute(sql);
        },
        version: 1,
      );
    } else {
      throw Exception("Unsupported platform");
    }
  }

  Future<void> _createThreadTable(String tag, int threadId) async {
    final Database db = await _database;

    final String sql =
        'CREATE TABLE ${tag}_$threadId(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, postId INTEGER, comment TEXT, timestamp INTEGER)';
    await db.execute(sql);
  }

  Future<void> removeThreadTable(String tag, int id) async {
    final Database db = await _database;

    await db.execute('DROP TABLE IF EXISTS ${tag}_$id');
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

  Future<void> addPost(
      String tag, int threadId, int postId, String comment) async {
    final Database db = await _database;

    if (!await _tableExists(tag, threadId)) {
      await _createThreadTable(tag, threadId);
    }

    /// check if already has in database
    final occurence = await db.query(
      '${tag}_$threadId',
      where: 'postId = ?',
      whereArgs: [postId],
      limit: 1,
    );
    if (occurence.isNotEmpty) {
      return;
    }

    await db.insert('${tag}_$threadId', {
      'postId': postId,
      'comment': removeHtmlTags(comment, links: false)
          .substring(0, min(comment.length, 50)),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> removePost(String tag, int threadId, int id) async {
    final Database db = await _database;
    if (!await _tableExists(tag, threadId)) return;

    await db.delete('${tag}_$threadId', where: 'postId = ?', whereArgs: [id]);
  }

  Future<List<int>> getHiddenPostIds(String tag, int threadId) async {
    final Database db = await _database;
    if (!await _tableExists(tag, threadId)) {
      return [];
    }
    final items = await db.rawQuery('SELECT postId FROM ${tag}_$threadId');
    List<int> hiddenThreads =
        items.map((item) => item['postId'] as int).toList();
    return hiddenThreads;
  }

  Future<List<HiddenPost>> getHiddenPosts(String tag, int threadId) async {
    final Database db = await _database;

    if (!await _tableExists(tag, threadId)) {
      return [];
    }
    final List<Map<String, dynamic>> maps = await db.query('${tag}_$threadId');

    return List.generate(maps.length, (i) {
      final map = maps[i];

      return HiddenPost(
        tag: tag,
        id: map['postId'],
        comment: map['comment'],
        timestamp: map['timestamp'],
      );
    });
  }

  Future<bool> _tableExists(String tag, int threadId) async {
    final Database db = await _database;
    return (await db.query('sqlite_master',
            where: 'name = ?', whereArgs: ['${tag}_$threadId']))
        .isNotEmpty;
  }
}

class HiddenPost {
  String tag;
  int id;
  String comment;
  int timestamp;
  HiddenPost({
    required this.tag,
    required this.id,
    required this.comment,
    required this.timestamp,
  });
}
