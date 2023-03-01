import '../models/board_json.dart';

import '../models/tree.dart';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

class ThreadService {
  ThreadService({required this.boardTag, required this.threadId});

  final String boardTag;
  final int threadId;

  /// Contains all comment tree roots.
  ///
  /// The tree comment system is a list of roots each is a reply to an OP-post
  /// or just a reply in the thread, or is an OP-post itself.
  /// Replies to OP-posts is not added as a children of the OP-post, but as a
  /// independent root.
  List<TreeNode<Post>>? _roots;

  Future<List<TreeNode<Post>>?> getRoots() async {
    if (_roots == null) {
      await loadThread();
    }
    return _roots;
  }

  /// PLain list of all posts in the thread.
  List<Post>? _posts;
  List<Post>? get getPosts => _posts;

  /// Contains thread information like maxNum, postsCount, etc.
  Root _threadInfo = Root();
  Root get getThreadInfo => _threadInfo;

  /// Sends GET request and gets thread information and list of posts.
  Future<http.Response> _getThreadResponse({bool isRefresh = false}) async {
    String url;
    http.Response response;

    if (const String.fromEnvironment('thread') == 'true') {
      String jsonString = await rootBundle.loadString(
          isRefresh ? 'assets/new_posts.json' : 'assets/thread.json');
      response = http.Response(jsonString, 200, headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
      });
    } else {
      // normal behavior
      url = (isRefresh)
          ? "https://2ch.hk/api/mobile/v2/after/$boardTag/$threadId/${_threadInfo.maxNum! + 1}"
          : "https://2ch.hk/$boardTag/res/${threadId.toString()}.json";

      response = await http.get(Uri.parse(url));
    }
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load thread, error ${response.statusCode}');
    }
  }

  /// Loads thread from scratch.
  Future<void> loadThread() async {
    final http.Response response = await _getThreadResponse();
    Root decodedResponse = Root.fromJson(jsonDecode(response.body));

    _posts = decodedResponse.threads!.first.posts;
    _threadInfo = decodedResponse;
    _threadInfo.opPostId = _posts!.first.id;
    _threadInfo.postsCount = _threadInfo.postsCount! + _posts!.length;
    _extendThumbnailLinks(_posts);
    _roots = TreeService(posts: _posts, threadInfo: _threadInfo).getRoots;
  }

  /// Refreshes thread with new posts. Adds new posts to the tree.
  Future<void> refreshThread() async {
    final http.Response response = await _getThreadResponse(isRefresh: true);
    List<Post> newPosts = postListFromJson(jsonDecode(response.body)["posts"]);
    _extendThumbnailLinks(newPosts);
    _posts!.addAll(newPosts);
    if (newPosts.isNotEmpty) {
      _threadInfo.maxNum = newPosts.last.id;
    }

    TreeService treeService =
        TreeService(posts: newPosts, threadInfo: _threadInfo);
    List<TreeNode<Post>>? newRoots = treeService.getRoots;

    if (newRoots!.isEmpty) return;
    for (var newRoot in newRoots) {
      for (var parentId in newRoot.data.parents) {
        if (parentId != _threadInfo.opPostId) {
          TreeService.findPost(_roots!, parentId)!.addNode(newRoot);
        } else {
          _roots!.add(newRoot);
        }
      }

      if (newRoot.data.parents.isEmpty) {
        _roots!.add(newRoot);
      }
    }
  }

  /// Extends image thumbnail links to a full link so it can be loaded directly.
  static void _extendThumbnailLinks(List<Post>? posts) {
    return posts?.forEach((post) {
      if (post.files != null) {
        for (var file in post.files!) {
          if (file.thumbnail != null) {
            file.thumbnail = "http://2ch.hk${file.thumbnail ?? ""}";
          }
        }
      }
    });
  }
}
