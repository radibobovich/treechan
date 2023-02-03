import 'board_json.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';

class ThreadContainer {
  List<TreeNode<Post>>? roots;
  List<Post>? posts;
  Root threadInfo = Root();
  ThreadContainer({this.posts});
}
