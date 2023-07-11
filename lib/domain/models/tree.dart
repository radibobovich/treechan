import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/json/json.dart';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:html/parser.dart' as html;

class Tree {
  Tree({required this.posts, required this.threadInfo});

  final List<Post> posts;

  final Root threadInfo;

  /// Contains all comment tree roots.
  ///
  /// The tree comment system is a list of roots each is a reply to an OP-post
  /// or just a reply in the thread, or is an OP-post itself.
  /// Replies to OP-posts is not added as a children of the OP-post, but as a
  /// independent root.
  List<TreeNode<Post>> _roots = [];

  List<TreeNode<Post>>? get getRoots => _roots;

  Future<List<TreeNode<Post>>> getTree() async {
    final prefs = await SharedPreferences.getInstance();
    _addPostParents();
    _roots = await compute(createTreeModel, {posts, threadInfo, prefs});
    return _roots;
  }

  /// Adds a list of parent posts to each post based on the comment html.
  void _addPostParents() {
    final stopwatch = Stopwatch()..start();
    for (var post in posts) {
      //take post comment
      final postCommentHtml = html.parse(post.comment);
      // find <a> tags which contains data-num attribute
      var aTags = postCommentHtml.getElementsByTagName("a");
      final parents = List<int>.empty(growable: true);
      for (var aTag in aTags) {
        final keys = aTag.attributes.keys;
        final values = aTag.attributes.values;
        Map<Object, String> attrMap = {}; // map
        for (int i = 0; i < keys.length; i++) {
          // create key-value pairs for attributes
          attrMap[keys.elementAt(i)] = values.elementAt(i);
        }
        // take data-num attribute, it points to a parent post
        if (attrMap.containsKey('data-num')) {
          int parent = int.parse(attrMap['data-num']!);
          parents.add(parent);
        }
      }
      post.parents = parents;
    }
    debugPrint('addPostParents() executed in ${stopwatch.elapsedMilliseconds}');
  }

  /// Finds post by id in the list of trees.
  static TreeNode<Post>? findPost(List<TreeNode<Post>> roots, int id) {
    // for (var root in roots doesn't work for some reason)
    for (int i = 0; i < roots.length; i++) {
      if (roots[i].data.id == id) {
        return roots[i];
      }

      TreeNode<Post>? result = _findPostInChildren(roots[i], id);
      if (result == null) {
        continue;
      }
      return result;
    }
    return null;
  }

  /// Called recursively.
  static TreeNode<Post>? _findPostInChildren(TreeNode<Post> node, int id) {
    // for (var child in node.children) doesn't work for some reason
    for (int i = 0; i < node.children.length; i++) {
      if (node.children[i].data.id == id) {
        return node.children[i];
      }
      TreeNode<Post>? result = _findPostInChildren(node.children[i], id);
      if (result == null) {
        continue;
      }
      return result;
    }
    return null;
  }
}

/// Creates list of comment roots.
/// This is a heavy function and it defined outside the class to use isolate.
Future<List<TreeNode<Post>>> createTreeModel(Set data) async {
  List<Post> posts = data.elementAt(0);
  Root threadInfo = data.elementAt(1);
  SharedPreferences prefs = data.elementAt(2);

  final Set<int> postIds = posts.map((post) => post.id!).toSet();

  final stopwatch = Stopwatch()..start();

  findChildren(posts);
  List<TreeNode<Post>>? roots = [];
  for (var post in posts) {
    if (post.parents.isEmpty ||
        post.parents.contains(threadInfo.opPostId) ||
        _hasExternalReferences(postIds, post.parents)) {
      // find posts which are replies to the OP-post
      TreeNode<Post> node = TreeNode<Post>(
        expanded: !prefs.getBool("postsCollapsed")!,
        data: post,
        id: post.id,
        children: post.id != threadInfo.opPostId
            ? _attachChildren(post, posts, prefs, 1)
            : [],
      );
      roots.add(node);
    }
  }
  debugPrint('createTreeModel() executed in ${stopwatch.elapsedMilliseconds}');
  return roots;
}

/// Called recursively to connect post children.
List<TreeNode<Post>> _attachChildren(
    Post post, List<Post> posts, SharedPreferences prefs, int depth) {
  // debugPrint('Depth: $depth, id: ${post.id}');
  var childrenToAdd = <TreeNode<Post>>[];
  // find all posts that are replying to this one
  List<int> children = post.children;
  for (var index in children) {
    post = posts[index];
    // add replies to them too
    childrenToAdd.add(TreeNode(
        data: post,
        children: _attachChildren(post, posts, prefs, depth + 1),
        expanded: !prefs.getBool("postsCollapsed")!));
  }
  return childrenToAdd;
}

List<Post> findChildren(List<Post> posts) {
  for (var cpost in posts) {
    List<int> childrenIndexes = [];
    for (int i = 0; i < posts.length; i++) {
      if (posts[i].parents.contains(cpost.id)) {
        childrenIndexes.add(i);
      }
    }
    cpost.children = childrenIndexes;
  }
  return posts;
}

/// Check if post has references to posts in other threads.
bool _hasExternalReferences(Set<int> postIds, List<int> referenceIds) {
  for (var referenceId in referenceIds) {
    // if there are no posts with that id in current thread, then it is an external reference
    if (!postIds.contains(referenceId)) {
      return true;
    }
  }
  return false;
}
