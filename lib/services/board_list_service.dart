import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/models/board_json.dart';
import 'dart:convert';

/// Returns a list of available boards saved in device memory, otherwise downloads it.
Future<List<Board>?> getBoards() async {
  SharedPreferences prefs;
  prefs = await SharedPreferences.getInstance();
  prefs.clear();
  String? boards = prefs.getString('boards');

  if (boards != null) {
    List<Board> boardList = boardListFromJson(jsonDecode(boards))!;
    return boardList;
  }
  String? downloadedBoards = await downloadBoards();
  if (downloadedBoards == null) {
    return List.empty();
    // means that you have to ask user to check internet
  }
  prefs.setString('boards', downloadedBoards);
  return boardListFromJson(jsonDecode(downloadedBoards));
}

Future<String?> downloadBoards() async {
  String url = "https://2ch.hk/api/mobile/v2/boards";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return response.body;
  }
  return null;
}
