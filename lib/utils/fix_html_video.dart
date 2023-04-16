import '../models/json/json.dart';
import '../services/board_service.dart';

/// Removes <video> tag from comment and adds file to files list.
void fixHtmlVideo(dynamic item, {SortBy? sortType}) {
  if (item is Thread) {
    _fixHtmlVideoInBoard(item);
  } else if (item is Post) {
    _fixHtmlVideoInThread(item);
  }
}

void _fixHtmlVideoInBoard(Thread thread) {
  if (!thread.posts[0].comment!.contains("<video")) return;
  String video = thread.posts[0].comment!.substring(
      thread.posts[0].comment!.indexOf("<video"),
      thread.posts[0].comment!.indexOf("</video>") + 8);
  String src =
      video.substring(video.indexOf('src="') + 5, video.indexOf('"></video>'));
  thread.posts[0].comment = thread.posts[0].comment!
      .substring(0, thread.posts[0].comment!.indexOf("<video"));
  thread.posts[0].files ??= [];
  thread.posts[0].files!.add(File(
      type: 10,
      path: "https://2ch.hk/$src",
      thumbnail: 'https://via.placeholder.com/640x360.png?text=No+Thumbnail'));
}

void _fixHtmlVideoInThread(Post post) {
  if (!post.comment!.contains("<video")) return;
  String video = post.comment!.substring(
      post.comment!.indexOf("<video"), post.comment!.indexOf("</video>") + 8);
  String src =
      video.substring(video.indexOf('src="') + 5, video.indexOf('"></video>'));
  post.comment = post.comment!.substring(0, post.comment!.indexOf("<video"));
  post.files ??= [];
  post.files!.add(File(
      type: 10,
      path: "https://2ch.hk/$src",
      thumbnail: 'https://via.placeholder.com/640x360.png?text=No+Thumbnail'));
}
