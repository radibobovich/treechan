import 'package:treechan/utils/fix_blank_space.dart';

import '../exceptions.dart';
import '../models/json/json.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/fix_html_video.dart';

enum SortBy { page, bump, time }

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

  Future<http.Response> _getBoardResponse() async {
    String url = "";
    if (sortType == SortBy.bump) {
      url = "https://2ch.hk/$boardTag/catalog.json";
    } else if (sortType == SortBy.time) {
      url = "https://2ch.hk/$boardTag/catalog_num.json";
    } else if (sortType == SortBy.page) {
      url = "https://2ch.hk/$boardTag/$currentPage.json";
      if (currentPage == 0) {
        url = "https://2ch.hk/$boardTag/index.json";
      }
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response;
    } else if (response.statusCode == 404) {
      throw BoardNotFoundException(message: 'Failed to load board.');
    } else {
      throw Exception(
          'Failed to load board $boardTag. Error code: ${response.statusCode}');
    }
  }

  Future<void> loadBoard() async {
    http.Response response = await _getBoardResponse();
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
    http.Response response = await _getBoardResponse();
    List<Thread>? newThreads =
        Root.fromJson(jsonDecode(response.body)).threads!;
    _threads = _threads! + newThreads;
  }
}
