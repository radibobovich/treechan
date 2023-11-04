import 'package:flutter/material.dart';
import 'package:treechan/data/board_fetcher.dart';
import 'package:treechan/data/local/filter_database.dart';
import 'package:treechan/di/injection.dart';
import 'package:treechan/domain/models/db/filter.dart';
import 'package:treechan/utils/fix_blank_space.dart';

import '../../utils/constants/enums.dart';

import '../../utils/fix_html_video.dart';
import '../models/core/core_models.dart';

class BoardRepository {
  BoardRepository(
      {required this.boardFetcher,
      required this.boardTag,
      this.currentPage = 0});
  final IBoardFetcher boardFetcher;
  final String boardTag;
  late String boardName;
  SortBy sortType = SortBy.page;
  int currentPage;
  List<Thread> _threads = [];

  Future<List<Thread>?> getThreads() async {
    if (_threads.isEmpty) {
      await load();
    }
    return _threads;
  }

  Future<bool> changeSortType(SortBy newSortType, String? searchTag) async {
    if (sortType != newSortType) {
      sortType = newSortType;
      currentPage = 0;
      await load();
      return true;
    }
    return false;
  }

  Future<void> load() async {
    currentPage = 0;
    final Board board =
        await boardFetcher.getBoardApiModel(currentPage, boardTag, sortType);

    boardName = board.name;
    _threads = await filterThreads(board.threads);
    for (var thread in _threads) {
      if (fixBlankSpace(thread.posts[0])) break;
    }
    for (var thread in _threads) {
      fixHtmlVideo(thread, sortType: sortType);
    }
  }

  Future<void> refresh() async {
    if (_threads.isEmpty) {
      return;
    }

    final Board board = await boardFetcher.getBoardApiModel(
        currentPage + 1, boardTag, sortType);

    List<Thread> newThreads = await filterThreads(board.threads);
    if (newThreads.isNotEmpty) {
      currentPage += 1;
    }
    debugPrint(currentPage.toString());
    for (var newThread in newThreads) {
      // if this thread has not been added before
      if (_threads.indexWhere((oldThread) =>
              oldThread.posts.first.id == newThread.posts.first.id) ==
          -1) {
        _threads.add(newThread);
      }
    }
  }

  /// Hides threads that matches autohide filter.
  Future<List<Thread>> filterThreads(List<Thread> threads) async {
    final db = await getIt<FilterDb>().instance;
    final List<FilterView> filters = await db.getFiltersForBoard(
        imageboard: boardFetcher.imageboard, boardTag: boardTag);
    filters.removeWhere((filter) => filter.enabled == false);

    for (Thread thread in threads) {
      for (FilterView filter in filters) {
        final regExp =
            RegExp(r"" + filter.pattern, caseSensitive: filter.caseSensitive);
        if (regExp.hasMatch(
            '${thread.posts.first.subject} ${thread.posts.first.comment}')) {
          thread.hidden = true;
        }
      }
    }
    return threads;
  }
}
