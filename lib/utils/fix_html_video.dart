import 'package:treechan/domain/models/core/core_models.dart';

import 'constants/enums.dart';

/// Removes <video> tag from comment and adds file to files list.
void fixHtmlVideo(dynamic item, {SortBy? sortType}) {
  if (item is Thread) {
    _fixHtmlVideoInBoard(item);
  } else if (item is Post) {
    _fixHtmlVideoInThread(item);
  }
}

void _fixHtmlVideoInBoard(Thread thread) {
  String comment = thread.posts.first.comment;
  if (!comment.contains("<video")) return;
  String video = comment.substring(
      comment.indexOf("<video"), comment.indexOf("</video>") + 8);
  String src =
      video.substring(video.indexOf('src="') + 5, video.indexOf('"></video>'));
  thread.posts.first.comment =
      comment.substring(0, thread.posts.first.comment.indexOf("<video")) +
          comment.substring(comment.indexOf("</video>") + 8);
  thread.posts.first.files?.add(File(
      name: '',
      fullName: '',
      displayName: '',
      size: 0,
      width: 100,
      height: 100,
      tnWidth: 100,
      tnHeight: 100,
      type: 10,
      path: "https://2ch.hk/$src",
      thumbnail: 'https://via.placeholder.com/640x360.png?text=No+Thumbnail'));
}

void _fixHtmlVideoInThread(Post post) {
  String comment = post.comment;
  if (!comment.contains("<video")) return;
  String video = comment.substring(
      comment.indexOf("<video"), comment.indexOf("</video>") + 8);
  String src =
      video.substring(video.indexOf('src="') + 5, video.indexOf('"></video>'));
  post.comment = comment.substring(0, comment.indexOf("<video")) +
      comment.substring(comment.indexOf("</video>") + 8);
  post.files?.add(File(
      name: '',
      fullName: '',
      displayName: '',
      size: 0,
      width: 100,
      height: 100,
      tnWidth: 100,
      tnHeight: 100,
      type: 10,
      path: "https://2ch.hk/$src",
      thumbnail: 'https://via.placeholder.com/640x360.png?text=No+Thumbnail'));
}
