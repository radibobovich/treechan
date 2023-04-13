import '../models/json/json.dart';

bool fixBlankSpace(Post post) {
  if (post.board == 'pr' && post.id == 1215536) {
    // trim <br> tag from the end of the comment
    post.comment = post.comment!.substring(0, post.comment!.length - 4);
  }
  return true;
}
