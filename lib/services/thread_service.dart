import 'package:http/http.dart' as http;
import 'package:treechan/board_json.dart';
import 'dart:convert';

Future<Thread?> getThread(String tag, int threadId) async {
  var url = "https://2ch.hk/" + tag + "/res/" + threadId.toString() + ".json";
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    var test = Root.fromJson(jsonDecode(response.body));
    var thread = Root.fromJson(jsonDecode(response.body)).threads?.first;
    thread?.posts?.forEach((post) {
      if (post.files != null) {
        for (var element in post.files!) {
          if (element.thumbnail != null) {
            element.thumbnail = "http://2ch.hk${element.thumbnail ?? ""}";
          }
        }
      }
    });
    return thread;
  } else {
    throw Exception('Failed to load thread, error ${response.statusCode}');
  }
}
