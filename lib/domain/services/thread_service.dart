import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/data/thread_fetcher.dart';
import 'package:treechan/main.dart';
import 'package:treechan/utils/fix_html_video.dart';

import '../models/json/json.dart';

import '../models/tree.dart';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../utils/fix_blank_space.dart';

class ThreadService {
  ThreadService({required this.boardTag, required this.threadId});

  final String boardTag;
  final int threadId;

  /// Contains all comment tree roots.
  ///
  /// The tree comment system is a list of roots each is a reply to an OP-post
  /// or just a reply in the thread, or is an OP-post itself.
  /// Replies to OP-posts are not added as a children of the OP-post, but as a
  /// independent root.
  List<TreeNode<Post>>? _roots;

  Future<List<TreeNode<Post>>?> getRoots() async {
    prefs = await SharedPreferences.getInstance();

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

  /// Loads thread from scratch.
  Future<void> loadThread() async {
    final ThreadFetcher fetcher = ThreadFetcher(
        boardTag: boardTag, threadId: threadId, threadInfo: _threadInfo);
    final http.Response response = await fetcher.getThreadResponse();
    Root decodedResponse = Root.fromJson(jsonDecode(response.body));

    _posts = decodedResponse.threads!.first.posts;
    if (_posts != null) fixBlankSpace(_posts!.first);
    _threadInfo = decodedResponse;
    _threadInfo.opPostId = _posts!.first.id;
    _threadInfo.postsCount = _threadInfo.postsCount! + _posts!.length;
    for (var post in _posts!) {
      if (post.comment!.contains("video")) fixHtmlVideo(post);
    }
    _roots = Tree(posts: _posts!, threadInfo: _threadInfo).getRoots;
    _threadInfo.showLines = true;

    final stopwatch = Stopwatch()..start();
    _setShowLinesProperty(_roots);
    debugPrint("Set showLines property in ${stopwatch.elapsedMilliseconds}");
  }

  /// Refreshes thread with new posts. Adds new posts to the tree.
  Future<void> refreshThread() async {
    final ThreadFetcher fetcher = ThreadFetcher(
        boardTag: boardTag, threadId: threadId, threadInfo: _threadInfo);
    final http.Response response =
        await fetcher.getThreadResponse(isRefresh: true);
    List<Post> newPosts = postListFromJson(jsonDecode(response.body)["posts"]);
    _threadInfo.postsCount = _threadInfo.postsCount! + newPosts.length;
    _threadInfo.maxNum = newPosts.last.id;
    _posts!.addAll(newPosts);
    if (newPosts.isNotEmpty) {
      _threadInfo.maxNum = newPosts.last.id;
    }
    // create tree for new posts
    Tree treeService = Tree(posts: newPosts, threadInfo: _threadInfo);
    List<TreeNode<Post>>? newRoots = treeService.getRoots;

    // attach new tree to the old tree
    if (newRoots!.isEmpty) return;
    for (var newRoot in newRoots) {
      for (var parentId in newRoot.data.parents) {
        if (parentId != _threadInfo.opPostId) {
          Tree.findPost(_roots!, parentId)!.addNode(newRoot);
        } else {
          _roots!.add(newRoot);
        }
      }

      if (newRoot.data.parents.isEmpty) {
        _roots!.add(newRoot);
      }
    }
    _setShowLinesProperty(_roots);
  }

  /// Sets showLines property to false when there are nodes with depth >=16.
  void _setShowLinesProperty(List<TreeNode<Post>>? roots) {
    if (prefs.getBool('2dscroll')!) {
      // 2d scroll is enabled so lines wont cross with the posts
      return;
    }
    for (var root in roots!) {
      for (var child in root.children) {
        _checkDepth(child);
      }
    }
  }

  /// Called recursively.
  void _checkDepth(TreeNode<Post> node) {
    if (node.depth >= 16) {
      _threadInfo.showLines = false;
      return;
    }

    for (var element in node.children) {
      _checkDepth(element);
    }
  }
}