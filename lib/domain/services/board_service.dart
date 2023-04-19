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
  List<Thread>? _threads;

  Future<List<Thread>?> getThreads() async {
    if (_threads == null) {
      await loadBoard();
    }
    return _threads;
  }

  Future<void> changeSortType(SortBy newSortType, String? searchTag) async {
    if (sortType != newSortType) {
      sortType = newSortType;
      currentPage = 0;
      await loadBoard();
    }
  }

  Future<void> loadBoard() async {
    final BoardFetcher fetcher =
        BoardFetcher(boardTag: boardTag, sortType: sortType);
    http.Response response = await fetcher.getBoardResponse(currentPage);
    boardName = Root.fromJson(jsonDecode(response.body)).board!.name!;
    _threads = Root.fromJson(jsonDecode(response.body)).threads!;
    for (var thread in _threads!) {
      if (fixBlankSpace(thread.posts[0])) break;
    }
    for (var thread in _threads!) {
      fixHtmlVideo(thread, sortType: sortType);
    }
    currentPage = 0;
  }

  Future<void> refreshBoard() async {
    currentPage += 1;
    final BoardFetcher fetcher =
        BoardFetcher(boardTag: boardTag, sortType: sortType);
    http.Response response = await fetcher.getBoardResponse(currentPage);
    List<Thread>? newThreads =
        Root.fromJson(jsonDecode(response.body)).threads!;
    _threads = _threads! + newThreads;
  }
}
