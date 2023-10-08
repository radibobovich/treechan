import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/main.dart';
import 'dart:convert';

import '../../data/board_list_fetcher.dart';
import '../models/category.dart';

class BoardListRepository {
  BoardListRepository({required this.fetcher, this.openAsCatalog});
  final BoardListFetcher fetcher;

  bool? openAsCatalog = false;
  final List<Category> _categories = [];
  final List<Board> _boards = [];
  List<Board> get boards => _boards;
  final List<Board> _favoriteBoards = [];

  Future<List<Category>> getCategories() async {
    if (_categories.isEmpty) {
      await load();
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
    _categories.clear();
    _boards.clear();
    _favoriteBoards.clear();
  }

  Future<void> load() async {
    final List<Board> boards = await fetcher.getBoards();

    _boards.addAll(boards);

    for (Board board in _boards) {
      if (board.category == "") {
        board.category = "Скрытые";
      }

      // find category in list and add board to it if category exists
      int categoryIndex = _categories
          .indexWhere((category) => category.categoryName == board.category);
      if (categoryIndex != -1) {
        _categories[categoryIndex].boards.add(board);
      } else {
        _categories
            .add(Category(categoryName: board.category, boards: [board]));
      }
    }
  }

  void _getFavoriteBoards() {
    String jsonBoards = prefs.getString("favoriteBoards") ?? "";
    if (jsonBoards == "") {
      return;
    }
    _favoriteBoards.addAll(_boardListFromJson(jsonDecode(jsonBoards)));
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

List<Board> _boardListFromJson(List<dynamic> json) {
  List<Board> boardList = List.empty(growable: true);
  for (var boardItem in json) {
    boardList.add(Board.fromJson(boardItem));
  }
  return boardList;
}
