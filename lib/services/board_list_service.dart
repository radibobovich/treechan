import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/json/json.dart';
import 'dart:convert';
import '../screens/board_list_screen.dart'; //TODO: move class to models

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

Future<List<Category>> getCategories() async {
  String? downloadedBoards = await downloadBoards();
  if (downloadedBoards == null) {
    return List.empty();
    // TODO: add error handling
  }
  List<Board>? boardList = boardListFromJson(jsonDecode(downloadedBoards));

  List<Category> categories = [];
  for (Board board in boardList!) {
    if (board.category == "") {
      board.category = "Скрытые";
    }

    // find category in list and add board to it if category exists
    int categoryIndex = categories
        .indexWhere((category) => category.categoryName == board.category!);
    if (categoryIndex != -1) {
      categories[categoryIndex].boards.add(board);
    } else {
      categories.add(Category(categoryName: board.category!, boards: [board]));
    }
  }
  return categories;
}
