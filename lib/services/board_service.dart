import '../models/json/json.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum SortBy { page, bump, time }

class BoardService {
  BoardService(
      {required this.boardTag, required this.sortType, this.currentPage = 0});

  final String boardTag;
  SortBy sortType;
  int currentPage;
  List<Thread>? _threads;

  Future<List<Thread>?> getThreads() async {
    if (_threads == null) {
      await loadBoard();
    }
    return _threads;
  }

  // TODO: add refresh
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
    } else {
      throw Exception('Failed to load board, error ${response.statusCode}');
    }
  }

  Future<void> loadBoard() async {
    http.Response response = await _getBoardResponse();
    _threads = Root.fromJson(jsonDecode(response.body)).threads!;
    _threads = _fixThreadInfo(_threads!);
    _threads = _extendThumbnailLinks(_threads!);
  }

  Future<void> refreshBoard() async {
    currentPage += 1;
    http.Response response = await _getBoardResponse();
    List<Thread>? newThreads =
        Root.fromJson(jsonDecode(response.body)).threads!;
    newThreads = _fixThreadInfo(newThreads);
    newThreads = _extendThumbnailLinks(newThreads);
    _threads = _threads! + newThreads;
  }

  List<Thread> _fixThreadInfo(List<Thread> threads) {
    if (sortType == SortBy.page) {
      for (var thread in threads) {
        thread.comment = thread.posts![0].comment;
        thread.subject = thread.posts![0].subject;
        thread.num_ = thread.posts![0].id;
        thread.email = thread.posts![0].email;
        thread.board = thread.posts![0].board;
        thread.name = thread.posts![0].name;
        thread.date = thread.posts![0].date;
        thread.files = thread.posts![0].files;
      }
    }
    return threads;
  }

  static List<Thread> _extendThumbnailLinks(List<Thread> threadList) {
    for (var thread in threadList) {
      if (thread.files != null) {
        thread.files?.forEach((element) {
          // make full link to image thumbnail
          if (element.thumbnail != null) {
            element.thumbnail = "http://2ch.hk${element.thumbnail}";
          }
        });
      }
    }
    return threadList;
  }
}
