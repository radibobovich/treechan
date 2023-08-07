import 'package:flutter/material.dart';
import 'package:treechan/data/board_fetcher.dart';
import 'package:treechan/utils/fix_blank_space.dart';

import '../../utils/constants/enums.dart';
import '../models/json/json.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../utils/fix_html_video.dart';

class BoardService {
  BoardService({required this.boardTag, this.currentPage = 0});

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

  Future<void> changeSortType(SortBy newSortType, String? searchTag) async {
    if (sortType != newSortType) {
      sortType = newSortType;
      currentPage = 0;
      await load();
    }
  }

  Future<void> load() async {
    currentPage = 0;
    final BoardFetcher fetcher =
        BoardFetcher(boardTag: boardTag, sortType: sortType);
    http.Response response = await fetcher.getBoardResponse(currentPage);
    boardName = Root.fromJson(jsonDecode(response.body)).board!.name!;
    _threads = Root.fromJson(jsonDecode(response.body)).threads!;
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
    final BoardFetcher fetcher =
        BoardFetcher(boardTag: boardTag, sortType: sortType);
    http.Response response = await fetcher.getBoardResponse(currentPage + 1);
    List<Thread> newThreads = Root.fromJson(jsonDecode(response.body)).threads!;
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
