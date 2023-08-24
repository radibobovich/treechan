import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/data/hidden_posts.database.dart';
import 'package:treechan/data/thread_fetcher.dart';
import 'package:treechan/main.dart';
import 'package:treechan/utils/fix_html_video.dart';

import '../models/json/json.dart';

import '../models/tree.dart';

import 'package:flexible_tree_view/flexible_tree_view.dart';

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
  final List<TreeNode<Post>> _roots = [];

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
  List<Post> get posts => _posts;

  /// Contains all nodes plain. Used for search. Key is post id.
  /// Note that multiple nodes can have the same post id,
  /// thats why value is a list of nodes.
  final Map<int, List<TreeNode<Post>>> _plainNodes = {};
  // Map<int, List<TreeNode<Post>>> get plainNodes => _plainNodes;
  List<TreeNode<Post>> nodesAt(int id) => _plainNodes[id] ?? [];

  final List<TreeNode<Post>> _lastNodes = [];
  List<TreeNode<Post>> get getLastNodes => _lastNodes;

  /// Contains thread information like maxNum, postsCount, etc.
  Root _threadInfo = Root();
  Root get threadInfo => _threadInfo;

  List<int> hiddenPosts = [];

  /// Sends GET request and gets thread information and list of posts.

  /// Loads thread from scratch.
  Future<void> load() async {
    final ThreadFetcher fetcher =
        ThreadFetcher(boardTag: boardTag, threadId: threadId);
    // final http.Response response = await fetcher.getThreadResponse();
    // Root decodedResponse = Root.fromJson(jsonDecode(response.body));
    // _posts = decodedResponse.threads!.first.posts;
    _posts = await fetcher.getPosts();
    _threadInfo = fetcher.threadInfo;
    if (_posts.isNotEmpty) fixBlankSpace(_posts.first);

    // _threadInfo = decodedResponse;

    _threadInfo.opPostId = _posts.first.id;
    _threadInfo.postsCount = _threadInfo.postsCount! + _posts.length;

    for (var post in _posts) {
      if (post.comment.contains("video")) fixHtmlVideo(post);
    }
    final record = await Tree(posts: _posts, threadInfo: _threadInfo).getTree();
    _roots.addAll(record.$1);
    _plainNodes.addAll(record.$2);

    _threadInfo.showLines = true;

    final stopwatch = Stopwatch()..start();
    _setShowLinesProperty(_roots);
    stopwatch.stop();
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
    // final http.Response response =
    //     await fetcher.getThreadResponse(isRefresh: true);
    // List<Post> newPosts = postListFromJson(jsonDecode(response.body)["posts"]);
    List<Post> newPosts = await fetcher.getPosts(isRefresh: true);
    if (newPosts.isEmpty) return;

    updateInfo(newPosts);
    _posts.addAll(newPosts);

    // create tree for new posts
    final Tree treeService = Tree(posts: newPosts, threadInfo: _threadInfo);

    /// This function actually updates [_roots].
    /// It returns [newPlainNodes] just to add them to [_lastNodes] more easily.
    final newPlainNodes = await treeService.attachNewRoots(
        _roots, _plainNodes, _posts, _threadInfo);

    _plainNodes.addAll(newPlainNodes);

    _lastNodes.clear();
    for (var nodeList in newPlainNodes.values) {
      _lastNodes.add(nodeList.first);
    }

    final stopwatch = Stopwatch()..start();
    _lastNodes.sort((a, b) => a.data.id.compareTo(b.data.id));
    stopwatch.stop();
    debugPrint(
        'New posts sort executed in ${stopwatch.elapsedMicroseconds} microseconds');

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
