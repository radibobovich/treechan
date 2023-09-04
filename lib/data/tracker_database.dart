import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../domain/models/tab.dart';

class TrackerDatabase {
  static final TrackerDatabase _instance = TrackerDatabase._internal();

  factory TrackerDatabase() {
    return _instance;
  }

  late Future<Database> _database;

  TrackerDatabase._internal() {
    _database = _createDatabase();
  }

  Future<Database> _createDatabase() async {
    const String sql1 =
        'CREATE TABLE thread_tracker(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, tag TEXT, threadId INTEGER, name TEXT, addTimestamp INTEGER, refreshTimestamp INTEGER, posts INTEGER, newPosts INTEGER, newReplies INTEGER, isDead INTEGER)';
    const String sql2 =
        'CREATE TABLE branch_tracker(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, tag TEXT, threadId INTEGER, branchId INTEGER, name TEXT, addTimestamp INTEGER, refreshTimestamp INTEGER, posts INTEGER, newPosts INTEGER, newReplies INTEGER, isDead INTEGER)';
    if (Platform.isWindows || Platform.isLinux) {
      databaseFactory = databaseFactoryFfi;
      return databaseFactory.openDatabase(
        join(await getDatabasesPath(), 'tracker_database.db'),
        options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) {
              db.execute(sql1);
              db.execute(sql2);
              return;
            }),
      );
    } else if (Platform.isAndroid || Platform.isIOS) {
      return openDatabase(
        join(await getDatabasesPath(), 'tracker_database.db'),
        onCreate: (db, version) {
          db.execute(sql1);
          db.execute(sql2);
          return;
        },
        version: 1,
      );
    } else {
      throw Exception("Unsupported platform");
    }
  }

  Future<void> addThread(
      String tag, int threadId, String name, int posts) async {
    final Database db = await _database;

    final occurence = await db.query('thread_tracker',
        where: 'threadId = ?', whereArgs: [threadId], limit: 1);
    if (occurence.isNotEmpty) return;

    await db.insert('thread_tracker', {
      'tag': tag,
      'threadId': threadId,
      'name': name,
      'addTimestamp': DateTime.now().millisecondsSinceEpoch,
      'refreshTimestamp': DateTime.now().millisecondsSinceEpoch,
      'posts': posts,
      'newPosts': 0,
      'newReplies': 0,
      'isDead': 0
    });
  }

  Future<void> removeThread(String tag, int threadId) async {
    final Database db = await _database;

    await db.delete('thread_tracker',
        where: 'threadId = ? AND tag = ?', whereArgs: [threadId, tag]);
  }

  Future<void> updateThread(
      {required String tag,
      required int threadId,
      required int? posts,
      required int newPosts,
      required int newReplies,
      bool forceNewPosts = false,
      bool forceNewReplies = false,
      required bool isDead}) async {
    final Database db = await _database;

    final Map<String, dynamic> currentValues = (await db.query('thread_tracker',
            where: 'threadId = ? AND tag = ?',
            whereArgs: [threadId, tag],
            limit: 1))
        .first;

    final updateValues = {
      'refreshTimestamp': DateTime.now().millisecondsSinceEpoch,
      'posts': posts ?? currentValues['posts'],
      'newPosts':
          forceNewPosts ? newPosts : currentValues['newPosts'] + newPosts,
      'newReplies': forceNewReplies
          ? newReplies
          : currentValues['newReplies'] + newReplies,
      'isDead': isDead ? 1 : currentValues['isDead'],
    };

    await db.update('thread_tracker', updateValues,
        where: 'threadId = ? AND tag = ?', whereArgs: [threadId, tag]);
  }

  Future<void> addBranch(
      String tag, int threadId, int branchId, String name, int posts) async {
    final Database db = await _database;

    final occurence = await db.query('branch_tracker',
        where: 'branchId = ?', whereArgs: [branchId], limit: 1);
    if (occurence.isNotEmpty) return;

    await db.insert('branch_tracker', {
      'tag': tag,
      'branchId': branchId,
      'threadId': threadId,
      'name': name,
      'addTimestamp': DateTime.now().millisecondsSinceEpoch,
      'refreshTimestamp': DateTime.now().millisecondsSinceEpoch,
      'posts': posts,
      'newPosts': 0,
      'newReplies': 0,
      'isDead': 0
    });
  }

  Future<void> removeBranch(String tag, int branchId) async {
    final Database db = await _database;

    await db.delete('branch_tracker',
        where: 'branchId = ? AND tag = ?', whereArgs: [branchId, tag]);
  }

  Future<void> updateBranch(
      {required String tag,
      required int branchId,
      int? posts,
      required int newPosts,
      required int newReplies,
      required bool isDead,
      bool forceNewPosts = false,
      bool forceNewReplies = false,
      int? threadId}) async {
    final Database db = await _database;

    final Map<String, dynamic> currentValues = (await db.query('branch_tracker',
            where: 'branchId = ? AND tag = ?',
            whereArgs: [branchId, tag],
            limit: 1))
        .first;

    final updateValues = {
      'refreshTimestamp': DateTime.now().millisecondsSinceEpoch,
      'posts': posts ?? currentValues['posts'],
      'newPosts':
          forceNewPosts ? newPosts : currentValues['newPosts'] + newPosts,
      'newReplies': forceNewReplies
          ? newReplies
          : currentValues['newReplies'] + newReplies,
      'isDead': isDead ? 1 : currentValues['isDead'],
    };

    await db.update('branch_tracker', updateValues,
        where: 'branchId = ? AND tag = ?', whereArgs: [branchId, tag]);
  }

  Future<void> markThreadAsRead(String tag, int threadId) async {
    final Database db = await _database;

    final updateValues = {
      'newPosts': 0,
      'newReplies': 0,
    };

    await db.update('thread_tracker', updateValues,
        where: 'threadId = ? AND tag = ?', whereArgs: [threadId, tag]);
  }

  Future<void> markBranchAsRead(String tag, int branchId, int threadId) async {
    final Database db = await _database;

    final updateValues = {
      'newPosts': 0,
      'newReplies': 0,
    };

    await db.update('branch_tracker', updateValues,
        where: 'branchId = ? AND tag = ? AND threadId = ?',
        whereArgs: [branchId, tag, threadId]);
  }

  Future<List<Map<String, dynamic>>> getTrackedThreads() async {
    final Database db = await _database;

    final List<Map<String, dynamic>> maps =
        await db.query('thread_tracker', orderBy: 'addTimestamp ASC');

    return maps;
  }

  Future<List<Map<String, dynamic>>> getTrackedBranches() async {
    final Database db = await _database;

    final List<Map<String, dynamic>> maps =
        await db.query('branch_tracker', orderBy: 'addTimestamp ASC');

    return maps;
  }

  Future<void> clear() async {
    final Database db = await _database;

    await db.delete('thread_tracker');
    await db.delete('branch_tracker');
  }

  Future<bool> isTracked(IdMixin tab) async {
    final Database db = await _database;
    List<Map<String, Object?>> occurence = [];
    if (tab is ThreadTab) {
      occurence = await db.query('thread_tracker',
          where: 'threadId = ? AND tag = ?',
          whereArgs: [tab.id, tab.tag],
          limit: 1);
    } else if (tab is BranchTab) {
      occurence = await db.query('branch_tracker',
          where: 'branchId = ? AND tag = ?',
          whereArgs: [tab.id, tab.tag],
          limit: 1);
    } else {
      throw Exception("Unsupported tab type");
    }
    return occurence.isNotEmpty;
  }
}
