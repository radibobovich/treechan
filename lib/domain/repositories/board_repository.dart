import 'package:flutter/material.dart';
import 'package:treechan/data/board_fetcher.dart';
import 'package:treechan/domain/repositories/repository.dart';
import 'package:treechan/utils/fix_blank_space.dart';

import '../../utils/constants/enums.dart';

import '../../utils/fix_html_video.dart';
import '../models/core/core_models.dart';

class BoardRepository implements Repository {
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

  @override
  Future<void> load() async {
    currentPage = 0;
    final Board board =
        await boardFetcher.getBoardApiModel(currentPage, boardTag, sortType);

    boardName = board.name;
    _threads = board.threads;
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

    List<Thread> newThreads = board.threads;
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
}
