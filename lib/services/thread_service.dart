import 'package:http/http.dart' as http;
import 'package:treechan/models/board_json.dart';
import 'dart:convert';
import '../models/thread_container.dart';

Future<ThreadContainer> getThreadRawData(String tag, int threadId,
    {bool isRefresh = false, int maxNum = 0}) async {
  ThreadContainer threadContainer = ThreadContainer();
  String url;
  url = (isRefresh && maxNum != 0)
      ? "https://2ch.hk/api/mobile/v2/after/$tag/$threadId/${maxNum + 1}"
      : "https://2ch.hk/$tag/res/${threadId.toString()}.json";
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    // if it is a refresh request
    if (isRefresh && maxNum != 0) {
      List<Post> newPosts =
          postListFromJson(jsonDecode(response.body)["posts"]);
      extendThumbnailLinks(newPosts);

      threadContainer.posts = newPosts;
      threadContainer.threadInfo =
          Root(maxNum: newPosts.isEmpty ? null : newPosts.last.id);
    } else {
      // if it is a get-thread request
      var threadResponse = Root.fromJson(jsonDecode(response.body));
      List<Post>? threadPosts = threadResponse.threads!.first.posts;

      threadResponse.opPostId = threadPosts!.first.id;
      extendThumbnailLinks(threadPosts);

      threadContainer.posts = threadPosts;
      threadContainer.threadInfo = threadResponse;
    }
    return threadContainer;
  } else {
    throw Exception('Failed to load thread, error ${response.statusCode}');
  }
}

void extendThumbnailLinks(List<Post>? posts) {
  return posts?.forEach((post) {
    if (post.files != null) {
      for (var element in post.files!) {
        if (element.thumbnail != null) {
          element.thumbnail = "http://2ch.hk${element.thumbnail ?? ""}";
        }
      }
    }
  });
}
