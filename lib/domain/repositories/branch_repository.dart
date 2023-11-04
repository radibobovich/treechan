import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/domain/repositories/thread_repository.dart';
import 'package:treechan/domain/repositories/tracker_repository.dart';

import '../../main.dart';
import '../../utils/constants/enums.dart';
import '../models/core/core_models.dart';
import '../models/tree.dart';
import 'repository.dart';

class BranchRepository implements Repository {
  BranchRepository({required this.threadRepository, required this.postId});
  final ThreadRepository threadRepository;
  final int postId;

  @override
  Imageboard get imageboard => threadRepository.imageboard;
  @override
  set imageboard(value) => threadRepository.imageboard = value;

  @override
  String get boardTag => threadRepository.boardTag;
  @override
  int get id => postId;

  /// Root node of the branch.
  TreeNode<Post>? _root;

  /// Returns the branch tree. Creates the tree if null.
  Future<TreeNode<Post>> getBranch() async {
    prefs = await SharedPreferences.getInstance();

    if (_root == null) {
      await load();
    }
    return _root!;
  }

  final List<Post> _posts = [];
  List<Post> get posts => _posts;

  int get postsCount => _posts.length;

  int newPostsCount = 0;

  int newReplies = 0;
  List<TreeNode<Post>> nodesAt(int id) => threadRepository.nodesAt(id);

  /// Gets posts from [threadRepository] and builds tree for a specific post.
  @override
  Future<void> load() async {
    List<Post> posts = threadRepository.posts;
    if (posts.isEmpty) {
      await threadRepository.load();
      posts = threadRepository.posts;
    }
    Post post = posts.firstWhere((element) => element.id == postId);
    _root = TreeNode(data: post)..expanded = true;
    final int postIndex = posts.indexOf(post);
    _root!.addNodes(await compute(_attachChildren,
        {post, postIndex, posts.sublist(postIndex), prefs, true}));

    Set<int> postIds = {};
    Tree.performForEveryNode(_root, (node) {
      bool isNew = postIds.add(node.data.id);
      if (isNew) _posts.add(node.data);
    });
  }

  /// Gets new added posts from [threadRepository], build its trees and attaches
  /// these trees to a current tree.
  Future<void> refresh(RefreshSource source,
      {int? lastIndex, TrackerRepository? trackerRepo}) async {
    assert(lastIndex != null || source != RefreshSource.thread,
        'You must provide lastIndex when refreshing related branches from thread');
    List<Post> posts;

    /// If refresh has been called from thread page you don't need to call
    /// [threadRepository.refresh] since it has already been called in
    /// [ThreadBloc]. You also can't get [lastIndex] directly in this case
    /// so it has been passed as an argument.
    ///
    /// Call chain looks like this:
    /// [ThreadBloc.add(RefreshThreadEvent)] -> [TabProvider.refreshRelatedBranches] ->
    /// -> [BranchBloc.add(RefreshBranchEvent())] -> [BranchService.refresh()]
    if (source == RefreshSource.branch || source == RefreshSource.tracker) {
      posts = threadRepository.posts;
      lastIndex = posts.length - 1;

      await threadRepository.refresh(trackerRepo: trackerRepo);
    }

    /// Get a list with new posts
    posts = threadRepository.posts;

    /// Trim posts to a new ones.
    List<Post> newPosts = posts.getRange(lastIndex! + 1, posts.length).toList();
    if (newPosts.isEmpty) {
      newPostsCount = 0;
      return;
    }

    /// Buila a tree from new posts.
    Tree treeService = Tree(
        posts: newPosts,
        opPostId: threadRepository.threadInfo.opPostId,
        oldPostsCount: lastIndex + 1);
    final record = await treeService.getTree(
        skipPostsModify: true, forceExpandNodes: true);
    final List<TreeNode<Post>> newRoots = record.$1;

    /// Attach obtained trees to the branch nodes.
    if (newRoots.isEmpty) {
      newPostsCount = 0;
      return;
    }
    for (var newRoot in newRoots) {
      for (var parentId in newRoot.data.parents) {
        if (parentId == threadRepository.threadInfo.opPostId) continue;
        // find a parent
        List<TreeNode<Post>> parentNodes =
            Tree.findAllNodes([_root!], parentId);
        // final List<TreeNode<Post>> parentNodes = nodesAt(parentId);
        for (var parentNode in parentNodes) {
          /// fix depth because here we add the same root in multiple places of the tree
          /// Depth will be also increased by one in [addNode] method
          parentNode.addNode(newRoot.copyWith(
              key: parentNode.data.id.toString() + newRoot.data.id.toString(),
              newKey: true)
            ..depth = parentNode.depth);

          // update children indexes list just in case
          parentNode.data.children.add(posts.indexOf(newRoot.data));
        }
      }
    }
    Set<int> oldPostIds = _posts.map((post) => post.id).toSet();
    Set<int> newPostIds = {};
    Tree.performForEveryNode(_root, (node) {
      final id = node.data.id;
      bool isNew = id > posts[lastIndex!].id &&
          newPostIds.add(id) &&
          !oldPostIds.contains(id);
      if (isNew) {
        _posts.add(node.data);
      }
    });
    newPostsCount = newPostIds.length;
  }
}

/// Attach all children of the post recursively.
/// This is an alternative to the function in Tree.dart, but with arguments
/// provided using Set, allowing compute() to be called directly.
Future<List<TreeNode<Post>>> _attachChildren(Set data) async {
  Post post = data.elementAt(0);
  int postIndex = data.elementAt(1);
  List<Post> posts = data.elementAt(2);
  SharedPreferences prefs = data.elementAt(3);
  bool? forceExpandNodes = data.elementAt(4);
  // int depth = data.elementAt(4);

  var childrenToAdd = <TreeNode<Post>>[];
  // find all posts that are replying to this one
  List<int> children = post.children;
  for (var index in children) {
    final Post child;
    child = posts[index - postIndex];
    // add replies to them too
    childrenToAdd.add(TreeNode(

        /// Make key unique to avoid
        /// GlobalObjectKey collisions due to roots the same root created at refresh
        /// attached in multiple places in the tree.
        key: UniqueKey().toString(),
        data: child,
        children: await _attachChildren(
            {child, postIndex, posts, prefs, forceExpandNodes}),
        expanded: forceExpandNodes ?? !prefs.getBool("postsCollapsed")!));
  }
  return childrenToAdd;
}
