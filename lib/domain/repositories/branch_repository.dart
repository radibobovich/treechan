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

  // Map<int, List<TreeNode<Post>>> get plainNodes => threadRepository.plainNodes;
  List<TreeNode<Post>> nodesAt(int id) => threadRepository.nodesAt(id);

  /// Gets posts from [threadRepository] and builds tree for a specific post.
  Future<void> load() async {
    List<Post> posts = threadRepository.posts;
    Post post = posts.firstWhere((element) => element.id == postId);
    _root = TreeNode(data: post);
    _root!.addNodes(await compute(
        _attachChildren, {post, posts.sublist(posts.indexOf(post)), prefs, 1}));
  }

  /// Gets new added posts from [threadRepository], build its trees and attaches
  /// these trees to a current tree.
  Future<void> refresh(RefreshSource source, {int? lastIndex}) async {
    List<Post> posts;

    /// If refresh has been called from thread page you don't need to call
    /// [threadRepository.refresh] since it has already been called in
    /// [ThreadBloc]. You also can't get [lastIndex] directly in this case
    /// so it has been passed as an argument.
    ///
    /// Call chain looks like this:
    /// [ThreadBloc.add(RefreshThreadEvent)] -> [TabProvider.refreshRelatedBranches] ->
    /// -> [BranchBloc.add(RefreshBranchEvent())] -> [BranchService.refresh()]
    if (source == RefreshSource.branch) {
      posts = threadRepository.posts;
      lastIndex = posts.length - 1;

      await threadRepository.refresh();
    }

    /// Get a list with new posts
    posts = threadRepository.posts;

    /// Trim posts to a new ones.
    List<Post> newPosts = posts.getRange(lastIndex! + 1, posts.length).toList();

    /// Buila a tree from new posts.
    Tree treeService =
        Tree(posts: newPosts, threadInfo: threadRepository.threadInfo);
    final record = await treeService.getTree(skipPostsModify: true);
    final List<TreeNode<Post>> newRoots = record.$1;

    /// Attach obtained trees to the branch nodes.
    if (newRoots.isEmpty) return;
    for (var newRoot in newRoots) {
      for (var parentId in newRoot.data.parents) {
        if (parentId == threadRepository.threadInfo.opPostId) continue;
        // find a parent
        // TreeNode<Post>? node = Tree.findFirstNode([_root!], parentId);
        final List<TreeNode<Post>> parentNodes = nodesAt(parentId);
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
  }
}

/// Attach all children of the post recursively.
/// This is an alternative to the function in Tree.dart, but with arguments
/// provided using Set, allowing compute() to be called directly.
Future<List<TreeNode<Post>>> _attachChildren(Set data) async {
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

        /// Make key unique to avoid
        /// GlobalObjectKey collisions due to roots the same root created at refresh
        /// attached in multiple places in the tree.
        key: UniqueKey().toString(),
        data: child,
        children: await _attachChildren({child, posts, prefs, depth + 1}),
        expanded: !prefs.getBool("postsCollapsed")!));
  }
  return childrenToAdd;
}
