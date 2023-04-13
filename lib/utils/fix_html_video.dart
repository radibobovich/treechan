import '../models/json/json.dart';

void fixHtmlVideo(dynamic item) {
  if (item is Thread) {
    _fixHtmlVideoInBoard(item);
  } else if (item is Post) {
    _fixHtmlVideoInThread(item);
  }
}

void _fixHtmlVideoInBoard(Thread thread) {
  String video = thread.posts![0].comment!.substring(
      thread.posts![0].comment!.indexOf("<video"),
      thread.posts![0].comment!.indexOf("</video>") + 8);
  String src =
      video.substring(video.indexOf('src="') + 5, video.indexOf('"></video>'));
  thread.posts![0].comment = thread.posts![0].comment!
      .substring(0, thread.posts![0].comment!.indexOf("<video"));
  thread.files ??= [];
  thread.files!.add(File(
      type: 10,
      path: "https://2ch.hk/$src",
      thumbnail: 'https://via.placeholder.com/640x360.png?text=No+Thumbnail'));
}

void _fixHtmlVideoInThread(Post post) {
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
