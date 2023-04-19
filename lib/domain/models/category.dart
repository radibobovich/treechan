import 'json/json.dart';

///Contains a list of boards which are separated by category
/// Example: Творчество (Доски: Дизайн, Столовая, Граффити)
/// Used in BoardListScreen.
class Category {
  Category({required this.categoryName, required this.boards});
  final String categoryName;
  final List<Board> boards;
}
