import '../models/board_json.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BoardService {
  BoardService({required this.boardTag});

  final String boardTag;

  List<Thread>? _threads;

  Future<List<Thread>?> getThreads() async {
    if (_threads == null) {
      await _getThreadsByBump();
    }
    return _threads;
  }

  // TODO: add refresh
  Future<void> _getThreadsByBump() async {
    String url = "https://2ch.hk/$boardTag/catalog.json";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      _threads = Root.fromJson(jsonDecode(response.body)).threads!;
      _threads = _extendThumbnailLinks(_threads!);
    } else {
      throw Exception('Failed to load board, error ${response.statusCode}');
    }
    return;
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
