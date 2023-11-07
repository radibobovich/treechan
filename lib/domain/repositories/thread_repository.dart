import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/data/local/hidden_posts.database.dart';
import 'package:treechan/data/thread/thread_loader.dart';
import 'package:treechan/data/thread/thread_refresher.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/domain/models/repository_stream.dart';
import 'package:treechan/domain/models/tab.dart';
import 'package:treechan/domain/repositories/tracker_repository.dart';
import 'package:treechan/exceptions.dart';
import 'package:treechan/main.dart';
import 'package:treechan/utils/constants/enums.dart';
import 'package:treechan/utils/fix_html_video.dart';

import '../models/thread_info.dart';
import '../models/tree.dart';

import 'package:flexible_tree_view/flexible_tree_view.dart';

import '../../utils/fix_blank_space.dart';
import 'repository.dart';

class ThreadRepository implements Repository {
  ThreadRepository({
    required this.imageboard,
    required this.boardTag,
    required this.threadId,
    this.archiveDate,
    required this.threadLoader,
    required this.threadRefresher,
    required bool classic,
    required StreamController<RepositoryMessage> messenger,
  })  : _classic = classic,
        _messenger = messenger;

  IThreadLoader threadLoader;
  IThreadRefresher threadRefresher;
  @override
  Imageboard imageboard;
  @override
  final String boardTag;
  final int threadId;

  /// Used by archive threads.
  String? archiveDate;

  /// If true, no roots will be built during load or refresh.
  bool _classic;

  bool get classic => _classic;

  final StreamController<RepositoryMessage> _messenger;
  @override
  int get id => threadId;

  /// Contains all comment tree roots.
  ///
  /// The tree comment system is a list of roots each is a reply to an OP-post
  /// or just a reply in the thread, or is an OP-post itself.
  /// Replies to OP-posts are not added as a children of the OP-post, but as a
  /// independent root.
  final List<TreeNode<Post>> _roots = [];

  /// For use in stateless widgets only. Prefer getRoots() instead.
  List<TreeNode<Post>> get getRootsSynchronously => _roots;

  /// Loads thread at first run and returns roots (if [classic] == false)
  /// Other times returns roots without loading.
  Future<List<TreeNode<Post>>> getRoots() async {
    prefs = await SharedPreferences.getInstance();

    if (_roots.isEmpty) {
      await load();
    }
    return _roots;
  }

  /// Loads thread at first run and returns posts (if [classic] == true)
  /// Other times returns roots without loading.
  Future<List<Post>> getPosts() async {
    prefs = await SharedPreferences.getInstance();

    if (_posts.isEmpty) {
      await load();
    }
    return _posts;
  }

  /// PLain list of all posts in the thread.
  List<Post> _posts = [];
  List<Post> get posts => _posts;

  int get postsCount => _posts.length;

  // TODO: move to ThreadInfo
  int newPostsCount = 0;

  int newReplies = 0;

  /// Contains all nodes plain. Used for search. Key is post id.
  /// Note that multiple nodes can have the same post id,
  /// thats why value is a list of nodes.
  final Map<int, List<TreeNode<Post>>> _plainNodes = {};
  List<TreeNode<Post>> nodesAt(int id) => _plainNodes[id] ?? [];
  Map<int, List<TreeNode<Post>>> get plainNodes => _plainNodes;

  final List<TreeNode<Post>> _lastNodes = [];
  List<TreeNode<Post>> get getLastNodes => _lastNodes;

  /// Contains thread information like maxNum, postsCount, etc.
  late ThreadInfo _threadInfo;
  ThreadInfo get threadInfo => _threadInfo;

  List<int> hiddenPosts = [];

  /// Sends GET request and gets thread information and list of posts.

  /// Loads thread from scratch.
  @override
  Future<void> load() async {
    try {
      _posts = await threadLoader.getPosts(
          boardTag: boardTag, threadId: threadId, date: archiveDate);
    } on ArchiveRedirectException catch (e) {
      _messenger.add(RepositoryRedirectRequest(
        repository: this,
        baseUrl: e.baseUrl,
        redirectPath: e.redirectPath,
      ));
      rethrow;
    }

    _threadInfo = ThreadInfo(
      boardTag: boardTag,
      id: threadId,
      title: _posts.first.subject,
      lastPostId: _posts.last.id,
      maxNum: _posts.last.id,
    );
    if (_posts.isNotEmpty) fixBlankSpace(_posts.first);

    for (var post in _posts) {
      if (post.comment.contains("video")) fixHtmlVideo(post);
    }

    final treeService = Tree(posts: _posts, opPostId: _threadInfo.id);

    /// Build tree only if thread is not in classic view.
    if (classic == false) {
      await _buildTree(treeService);
    } else {
      /// Find post parents and children manually
      treeService.findPostParents();
      findChildren(posts, 0);
    }

    hiddenPosts =
        await HiddenPostsDatabase().getHiddenPostIds(boardTag, threadId);
  }

  /// Builds posts tree on [load] call or when [changeView] sets tree mode.
  Future<void> _buildTree(Tree tree) async {
    final record = await tree.getTree();
    _roots.addAll(record.$1);
    _plainNodes.addAll(record.$2);

    _threadInfo.showLines = true;

    final stopwatch = Stopwatch()..start();
    _setShowLinesProperty(_roots);
    stopwatch.stop();
    debugPrint("Set showLines property in ${stopwatch.elapsedMilliseconds}");
  }

  /// Refreshes thread with new posts. Adds new posts to the tree.
  ///
  /// Branches are calling this method when they are refreshed,
  /// bypassing [ThreadBloc] refresh method, so you should use
  /// [trackerRepo] when refreshing branch to update tracker from here.
  Future<void> refresh({TrackerRepository? trackerRepo}) async {
    /// If thread hasn't been loaded properly you can't refresh it
    /// RefreshThreadEvent will fire LoadThreadEvent after so it will be loaded
    if (_posts.isEmpty) {
      return;
    }
    final int oldPostsCount = _posts.length;

    List<Post> newPosts = await threadRefresher.getNewPosts(
        boardTag: boardTag, threadId: threadId, lastPostId: _threadInfo.maxNum);
    newPostsCount = newPosts.length;
    if (newPosts.isEmpty) return;
    if (classic == true) {
      /// Find post children manually
      newPosts = findChildren(newPosts, oldPostsCount);
    }
    _updateInfo(newPosts);
    _posts.addAll(newPosts);

    // pass new posts so later we call attachNewRoots which will
    // build mini trees from new posts and attach them to the main tree
    final Tree treeService = Tree(
      posts: newPosts,
      opPostId: _threadInfo.id,
      oldPostsCount: oldPostsCount,
    );

    /// Update tree only if thread is not in classic view.
    if (classic == false) {
      /// This function actually updates [_roots].
      /// It returns [newPlainNodes] just to add them to [_lastNodes] more easily.
      final newPlainNodes = await treeService.attachNewRoots(
          _roots, _plainNodes, _posts, _threadInfo.id);

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
    } else {
      /// Find post parents manually
      treeService.findPostParents();

      /// Convert to a map to search faster by id
      final Map<int, Post> postsMap = {
        for (var post in _posts) (post).id: post
      };

      /// Add new posts as a children to the old ones
      for (int i = 0; i < newPosts.length; i++) {
        final post = newPosts[i];
        final parents = post.parents;
        for (int parentId in parents) {
          postsMap[parentId]?.children.add(i + oldPostsCount);
        }
      }
    }
    trackerRepo?.updateThreadByTab(
      tab: ThreadTab(
          name: null,
          imageboard: imageboard,
          tag: boardTag,
          prevTab: boardListTab,
          id: threadId,
          classic: classic),
      posts: postsCount,
      newPosts: newPostsCount,
      newReplies: newReplies,
    );
    return;
  }

  /// Toggles thread classic/tree view.
  Future<void> changeView() async {
    if (classic == false) {
      _classic = true;
      _roots.clear();
      _lastNodes.clear();
    } else {
      _classic = false;
      final tree = Tree(posts: _posts, opPostId: _threadInfo.id);
      await _buildTree(tree);
    }
  }

  void _updateInfo(List<Post> newPosts) {
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
