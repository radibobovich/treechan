import 'package:http/http.dart' as http;
import 'package:treechan/models/board_json.dart';
import 'dart:convert';
import '../models/thread_container.dart';
import 'package:flutter/services.dart';

/// Sends GET request and gets thread information and list of posts.
Future<ThreadContainer> getThreadRawData(String tag, int threadId,
    {bool isRefresh = false, int maxNum = 0}) async {
  ThreadContainer threadContainer = ThreadContainer();
  String url;
  http.Response response;

  if (const String.fromEnvironment('thread') == 'true') {
    String jsonString = await rootBundle
        .loadString(isRefresh ? 'assets/new_posts.json' : 'assets/thread.json');
    response = http.Response(jsonString, 200);
  } else {
    // normal behavior
    url = (isRefresh && maxNum != 0)
        ? "https://2ch.hk/api/mobile/v2/after/$tag/$threadId/${maxNum + 1}"
        : "https://2ch.hk/$tag/res/${threadId.toString()}.json";

    response = await http.get(Uri.parse(url));
  }
  if (response.statusCode == 200) {
    // if it is a refresh request
    if (isRefresh) {
      List<Post> newPosts =
          postListFromJson(jsonDecode(response.body)["posts"]);
      extendThumbnailLinks(newPosts);

      threadContainer.posts = newPosts;
      threadContainer.threadInfo =
          Root(maxNum: newPosts.isEmpty ? null : newPosts.last.id);
    } else {
      // if it is a get-full-thread request
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

/// Extends image thumbnail links to a full link.
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
