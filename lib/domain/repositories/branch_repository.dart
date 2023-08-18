import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/domain/repositories/thread_repository.dart';

import '../../main.dart';
import '../../utils/constants/enums.dart';
import '../models/json/json.dart';
import '../models/tree.dart';

class BranchRepository {
  BranchRepository({required this.threadRepository, required this.postId});
  final ThreadRepository threadRepository;
  final int postId;

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

  /// Gets posts from [threadRepository] and builds tree for a specific post.
  Future<void> load() async {
    List<Post> posts = threadRepository.getPosts;
    Post post = posts.firstWhere((element) => element.id == postId);
    _root = TreeNode(data: post);
    _root!.addNodes(await compute(_attachChildren, {post, posts, prefs, 1}));
  }

  /// Gets new added posts from [threadRepository], build its trees and attaches
  /// these trees to a current tree.
  Future<void> refresh(RefreshSource source, {int? lastIndex}) async {
    List<Post> posts;

    /// If refresh has been called from thread page you don't need to call
    /// [threadService.refresh] since it has already been called in
    /// [ThreadBloc]. You also can't get [lastIndex] directly in this case
    /// so it has been passed as an argument.
    ///
    /// Call chain looks like this:
    /// [ThreadBloc.add(RefreshThreadEvent)] -> [TabProvider.refreshRelatedBranches] ->
    /// -> [BranchBloc.add(RefreshBranchEvent())] -> [BranchService.refresh()]
    if (source == RefreshSource.branch) {
      posts = threadRepository.getPosts;
      lastIndex = posts.length - 1;

      await threadRepository.refresh();
    }

    /// Get a list with new posts
    posts = threadRepository.getPosts;

    /// Trim posts to a new ones.
    List<Post> newPosts = posts.getRange(lastIndex! + 1, posts.length).toList();

    /// Buila a tree from new posts.
    Tree treeService =
        Tree(posts: newPosts, threadInfo: threadRepository.getThreadInfo);
    List<TreeNode<Post>> newRoots =
        await treeService.getTree(skipPostsModify: true);

    /// Attach obtained trees to the branch nodes.
    if (newRoots.isEmpty) return;
    for (var newRoot in newRoots) {
      for (var parentId in newRoot.data.parents) {
        if (parentId == threadRepository.getThreadInfo.opPostId) continue;
        // find a parent
        TreeNode<Post>? node = Tree.findNode([_root!], parentId);
        if (node != null) {
          node.addNode(newRoot);
          // update children indexes list just in case
          node.data.children.add(posts.indexOf(newRoot.data));
        }
      }
    }
  }
}

/// Attach all children of the post recursively.
/// This is an alternative to the function in Tree.dart, but with arguments
/// provided using Set, allowing compute() to be called directly.
Future<List<TreeNode<Post>>> _attachChildren(Set data) async {
  // TODO: optimization: trim posts before current by id
  Post post = data.elementAt(0);
  List<Post> posts = data.elementAt(1);
  SharedPreferences prefs = data.elementAt(2);
  int depth = data.elementAt(3);
  var childrenToAdd = <TreeNode<Post>>[];
  // find all posts that are replying to this one
  List<int> children = post.children;
  for (var index in children) {
    final child = posts[index];
    // add replies to them too
    childrenToAdd.add(TreeNode(
        data: child,
        children: await _attachChildren({child, posts, prefs, depth + 1}),
        expanded: !prefs.getBool("postsCollapsed")!));
  }
  return childrenToAdd;
}
