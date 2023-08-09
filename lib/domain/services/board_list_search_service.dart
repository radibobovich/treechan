import '../models/json/json.dart';

class BoardListSearchService {
  BoardListSearchService({required this.boards});
  final List<Board> boards;

  List<Board> search(String query) {
    if (query.isEmpty) {
      return boards;
    }
    return boards
        .where((board) => (board.id! + board.name!)
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
  }
}
