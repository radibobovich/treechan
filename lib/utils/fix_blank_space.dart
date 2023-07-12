import '../domain/models/json/json.dart';

bool fixBlankSpace(Post post) {
  if (post.board == 'pr' && post.id == 1215536) {
    // trim <br> tag from the end of the comment
    post.comment = post.comment.substring(0, post.comment.length - 4);
  }
  return true;
}

// bool fixBlankSpaceThread(Thread thread) {
//   if (thread.board == 'pr' && thread.num_ == 1215536) {
//     // trim <br> tag from the end of the comment
//     thread.comment = thread.comment!.substring(0, thread.comment!.length - 4);
//   }
//   return true;
// }
