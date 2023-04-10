import 'package:http/http.dart' as http;
import 'package:treechan/main.dart';
import '../models/category.dart';
import '../models/json/json.dart';
import 'dart:convert';

class BoardListService {
  BoardListService();

  List<Category> _categories = List.empty(growable: true);
  List<Board> _favoriteBoards = List.empty(growable: true);

  Future<List<Category>> getCategories() async {
    if (_categories.isEmpty) {
      await _getCategories();
    }
    return _categories;
  }

  List<Board> getFavoriteBoards() {
    if (_favoriteBoards.isEmpty) {
      _getFavoriteBoards();
    }
    return _favoriteBoards;
  }

  Future<void> refreshBoardList() async {
    _categories = [];
  }

  static Future<String?> _downloadBoards() async {
    String url = "https://2ch.hk/api/mobile/v2/boards";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.body;
    }
    return null;
  }

  Future<void> _getCategories() async {
    String? downloadedBoards = await _downloadBoards();
    if (downloadedBoards == null) {
      // TODO: add error handling
      return;
    }
    List<Board>? boardList = boardListFromJson(jsonDecode(downloadedBoards));

    for (Board board in boardList) {
      if (board.category == "") {
        board.category = "Скрытые";
      }

      // find category in list and add board to it if category exists
      int categoryIndex = _categories
          .indexWhere((category) => category.categoryName == board.category!);
      if (categoryIndex != -1) {
        _categories[categoryIndex].boards.add(board);
      } else {
        _categories
            .add(Category(categoryName: board.category!, boards: [board]));
      }
    }
  }

  void _getFavoriteBoards() {
    String jsonBoards = prefs.getString("favoriteBoards") ?? "";
    if (jsonBoards == "") {
      return;
    }
    _favoriteBoards = boardListFromJson(jsonDecode(jsonBoards));
  }

  void saveFavoriteBoards(List<Board> boards) {
    String jsonBoards = jsonEncode(boards);
    prefs.setString("favoriteBoards", jsonBoards);
  }

  void addToFavorites(Board board) {
    if (_favoriteBoards.contains(board)) {
      return;
    }
    board.position = _favoriteBoards.length;
    _favoriteBoards.add(board);
    saveFavoriteBoards(_favoriteBoards);
  }

  void removeFromFavorites(Board board) {
    if (!_favoriteBoards.contains(board)) {
      return;
    }
    _favoriteBoards.remove(board);
    saveFavoriteBoards(_favoriteBoards);
  }
}
