import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/data/hidden_posts.database.dart';
import 'package:treechan/data/thread_fetcher.dart';
import 'package:treechan/main.dart';
import 'package:treechan/utils/fix_html_video.dart';

import '../models/json/json.dart';

import '../models/tree.dart';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../utils/fix_blank_space.dart';

class ThreadRepository {
  ThreadRepository({required this.boardTag, required this.threadId});

  final String boardTag;
  final int threadId;

  /// Contains all comment tree roots.
  ///
  /// The tree comment system is a list of roots each is a reply to an OP-post
  /// or just a reply in the thread, or is an OP-post itself.
  /// Replies to OP-posts are not added as a children of the OP-post, but as a
  /// independent root.
  List<TreeNode<Post>> _roots = [];

  /// For use in stateless widgets only. Prefer getRoots() instead.
  List<TreeNode<Post>> get getRootsSynchronously => _roots;

  /// Loads thread at first run and returns roots.
  /// Other times returns roots without loading.
  Future<List<TreeNode<Post>>> getRoots() async {
    prefs = await SharedPreferences.getInstance();

    if (_roots.isEmpty) {
      await load();
    }
    return _roots;
  }

  /// PLain list of all posts in the thread.
  List<Post> _posts = [];
  List<Post> get getPosts => _posts;

  /// All nodes linearized.
  final List<TreeNode<Post>> _lastNodes = [];
  List<TreeNode<Post>> get getLastNodes => _lastNodes;

  /// Contains thread information like maxNum, postsCount, etc.
  Root _threadInfo = Root();
  Root get getThreadInfo => _threadInfo;

  List<int> hiddenPosts = [];

  /// Sends GET request and gets thread information and list of posts.

  /// Loads thread from scratch.
  Future<void> load() async {
    final ThreadFetcher fetcher = ThreadFetcher(
        boardTag: boardTag, threadId: threadId, threadInfo: _threadInfo);
    final http.Response response = await fetcher.getThreadResponse();
    Root decodedResponse = Root.fromJson(jsonDecode(response.body));

    _posts = decodedResponse.threads!.first.posts;
    if (_posts.isNotEmpty) fixBlankSpace(_posts.first);
    _threadInfo = decodedResponse;
    _threadInfo.opPostId = _posts.first.id;
    _threadInfo.postsCount = _threadInfo.postsCount! + _posts.length;
    for (var post in _posts) {
      if (post.comment.contains("video")) fixHtmlVideo(post);
    }
    _roots = await Tree(posts: _posts, threadInfo: _threadInfo).getTree();
    _threadInfo.showLines = true;

    final stopwatch = Stopwatch()..start();
    _setShowLinesProperty(_roots);
    debugPrint("Set showLines property in ${stopwatch.elapsedMilliseconds}");
    hiddenPosts =
        await HiddenPostsDatabase().getHiddenPostIds(boardTag, threadId);
  }

  /// Refreshes thread with new posts. Adds new posts to the tree.
  Future<void> refresh() async {
    /// If thread hasn't been loaded properly you can't refresh it
    /// RefreshThreadEvent will fire LoadThreadEvent after so it will be loaded
    if (_posts.isEmpty) {
      return;
    }
    final ThreadFetcher fetcher = ThreadFetcher(
        boardTag: boardTag, threadId: threadId, threadInfo: _threadInfo);
    // TODO: move response processing to ThreadFetcher
    final http.Response response =
        await fetcher.getThreadResponse(isRefresh: true);
    List<Post> newPosts = postListFromJson(jsonDecode(response.body)["posts"]);
    if (newPosts.isEmpty) return;

    updateInfo(newPosts);

    _posts.addAll(newPosts);

    // create tree for new posts
    Tree treeService = Tree(posts: newPosts, threadInfo: _threadInfo);
    List<TreeNode<Post>> newRoots = await treeService.getTree();

    Tree.performForEveryNodeInRoots(newRoots, (node) {
      _lastNodes.add(node);
    });
    final stopwatch = Stopwatch()..start();

    _lastNodes.sort((a, b) => a.data.id.compareTo(b.data.id));
    debugPrint(
        'New posts sort executed in ${stopwatch.elapsedMicroseconds} microseconds');
    // attach new tree to the old tree
    if (newRoots.isEmpty) return;
    for (var newRoot in newRoots) {
      for (var parentId in newRoot.data.parents) {
        if (parentId != _threadInfo.opPostId) {
          // Find a node to attach new tree to
          // TODO: works bad because findNode returns only first occurence
          // leads to some posts are not there
          // to an old node which has 2 and more parents
          // + one node instance attaches to multiple nodes
          // it breaks reply link highlight in case if new root answers
          // and it also breaks depth lines
          if (newRoot.data.id == 282649173) {
            debugPrint('gotcha');
          }
          final node = Tree.findNode(_roots, parentId);
          node!.addNode(newRoot);

          /// find index of a child to add it to children list of a post
          int childIndex =
              _posts.indexWhere((element) => element.id == newRoot.data.id);

          /// update children in [node.data]
          node.data.children.add(childIndex);

          /// find index of a parent post to update his children list too
          int nodeIndex =
              _posts.indexWhere((element) => element.id == node.data.id);

          /// update children in [_posts]
          _posts[nodeIndex].children.add(childIndex);
        } else {
          _roots.add(newRoot);
        }
      }

      if (newRoot.data.parents.isEmpty) {
        _roots.add(newRoot);
      }
    }
    _setShowLinesProperty(_roots);
  }

  void updateInfo(List<Post> newPosts) {
    _threadInfo.postsCount = _threadInfo.postsCount! + newPosts.length;
    _threadInfo.maxNum = newPosts.last.id;

    /// Highlight new posts and force update numbers
    /// because refresh response does not contain numbers
    for (int i = 0; i < newPosts.length; i++) {
      newPosts[i].isHighlighted = true;
      newPosts[i].number = i + _posts.length + 1;
    }
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