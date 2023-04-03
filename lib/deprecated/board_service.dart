import 'package:http/http.dart' as http;
import 'package:treechan/models/board_json.dart';
import 'dart:convert';

Future<List<Thread>?> getThreadsByBump(String tag) async {
  String url = "https://2ch.hk/$tag/catalog.json";

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    List<Thread> threadList = Root.fromJson(jsonDecode(response.body)).threads!;

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
  } else {
    throw Exception('Failed to load board, error ${response.statusCode}');
  }
}
