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

  Future<List<TreeNode<Post>>> getTree({bool skipPostsModify = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!skipPostsModify) {
      _findPostParents();
    }
    findChildren(posts);

    _roots = await compute(_createTreeModel, {posts, threadInfo, prefs});
    return _roots;
  }

  /// Adds a list of parent posts to each post based on the comment html.
  void _findPostParents() {
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

  /// Finds (first node by post id in the list of trees.
  /// Worth noting that there might be multiple nodes containing same post
  // TODO: make it search all occurences

  static TreeNode<Post>? findNode(List<TreeNode<Post>> roots, int id) {
    final stopwatch = Stopwatch()..start();
    // for (var root in roots doesn't work for some reason)
    for (int i = 0; i < roots.length; i++) {
      if (roots[i].data.id == id) {
        debugPrint(
            'findNode() executed in ${stopwatch.elapsedMicroseconds} microseconds');
        return roots[i];
      }

      TreeNode<Post>? result = _findNodeInChildren(roots[i], id);
      if (result == null) {
        continue;
      }
      debugPrint(
          'findNode() executed in ${stopwatch.elapsedMicroseconds} microseconds');

      return result;
    }
    return null;
  }

  /// Called recursively.
  /// TODO: make it search all occurences
  
  static TreeNode<Post>? _findNodeInChildren(TreeNode<Post> node, int id) {
    // for (var child in node.children) doesn't work for some reason
    for (int i = 0; i < node.children.length; i++) {
      if (node.children[i].data.id == id) {
        return node.children[i];
      }
      TreeNode<Post>? result = _findNodeInChildren(node.children[i], id);
      if (result == null) {
        continue;
      }
      return result;
    }
    return null;
  }

  static TreeNode<Post> findRootNode(TreeNode<Post> node) {
    if (node.parent == null) {
      return node;
    }
    return findRootNode(node.parent!);
  }

  /// Expands all nodes in the branch that contains this node.
  /// Returns root node.
  static TreeNode<Post> expandParentNodes(TreeNode<Post> node) {
    if (node.parent == null) {
      return node;
    }
    node.parent!.expanded = true;
    return expandParentNodes(node.parent!);
  }

  /// Counts all nodes in the tree.
  static int countNodes(TreeNode<Post> node) {
    int count = 1;
    for (var child in node.children) {
      count += 1;
      count += _countForChildren(child);
    }
    return count;
  }

  /// Called recursively for all the children.
  static int _countForChildren(TreeNode<Post> node) {
    int count = 0;
    for (var child in node.children) {
      count += 1;
      count += _countForChildren(child);
    }
    return count;
  }

  /// Performs operation with every node in every tree.
  static void performForEveryNodeInRoots(
      List<TreeNode<Post>> roots, Function(TreeNode<Post> node) fn) {
    final stopwatch = Stopwatch()..start();

    for (var root in roots) {
      performForEveryNode(root, fn);
    }
    debugPrint(
        'performForEveryNodeInRoots() executed in ${stopwatch.elapsedMicroseconds} microseconds');
  }

  /// Performs operation with every node in this tree.
  static void performForEveryNode(
      TreeNode<Post>? node, Function(TreeNode<Post> node) fn) {
    if (node == null) {
      return;
    }
    fn(node);
    for (var child in node.children) {
      performForEveryNode(child, fn);
    }
  }
}

/// Creates list of comment roots.
/// This is a heavy function and defined outside the class to use in an isolate.
Future<List<TreeNode<Post>>> _createTreeModel(Set data) async {
  List<Post> posts = data.elementAt(0);
  Root threadInfo = data.elementAt(1);
  SharedPreferences prefs = data.elementAt(2);

  final Set<int> postIds = posts.map((post) => post.id).toSet();

  final stopwatch = Stopwatch()..start();

  List<TreeNode<Post>>? roots = [];

  /// In case of thread refresh function [_isExternalReference()] works
  /// to determine if the post replies to the old posts in the thread
  /// since at refresh we dont have previous posts list, so if it can't
  /// find it in the postIds it returns true.
  for (var post in posts) {
    if (post.parents.isEmpty ||
        post.parents.contains(threadInfo.opPostId) ||
        _isExternalReference(postIds, post.parents)) {
      // find posts which are replies to the OP-post
      TreeNode<Post> node = TreeNode<Post>(
        expanded: !prefs.getBool("postsCollapsed")!,
        data: post,
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
  var childrenToAdd = <TreeNode<Post>>[];
  // find all posts that are replying to this one
  List<int> children = post.children;
  for (var index in children) {
    // if (index >= posts.length) continue;
    final child = posts[index];
    // add replies to them too
    childrenToAdd.add(TreeNode(
        data: child,
        children: _attachChildren(child, posts, prefs, depth + 1),
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

/// Check if post has references to posts in other threads or
/// in case of thread refresh, if post replies to the old posts.
bool _isExternalReference(Set<int> postIds, List<int> referenceIds) {
  for (var referenceId in referenceIds) {
    // if there are no posts with that id in current thread, then it is an
    // external reference (or a reference to an old post)
    if (!postIds.contains(referenceId)) {
      return true;
    }
  }
  return false;
}
