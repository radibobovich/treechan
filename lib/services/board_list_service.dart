import 'package:http/http.dart' as http;
import 'package:treechan/board_json.dart';
import 'dart:convert';

Future<List<Board>?> getBoards() async {
  var url = "https://2ch.hk/api/mobile/v2/boards";

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    var boardList = BoardList.fromJson(jsonDecode(response.body));
    return boardList.boardList;
  } else {
    throw Exception('Failed to load board list, error ${response.statusCode}');
  }
}
