import 'package:flutter/material.dart';
import 'package:treechan/main.dart';

import '../models/json/json.dart';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:html/parser.dart' as html;

class TreeService {
  TreeService({required this.posts, required this.threadInfo}) {
    _addPostParents();
    _createTreeModel();
  }

  final List<Post> posts;

  final Root threadInfo;

  /// Contains all comment tree roots.
  ///
  /// The tree comment system is a list of roots each is a reply to an OP-post
  /// or just a reply in the thread, or is an OP-post itself.
  /// Replies to OP-posts is not added as a children of the OP-post, but as a
  /// independent root.
  final List<TreeNode<Post>> _roots =
      List<TreeNode<Post>>.empty(growable: true);

  List<TreeNode<Post>>? get getRoots => _roots;

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

  void _createTreeModel() {
    final stopwatch = Stopwatch()..start();
    for (var post in posts) {
      if (post.parents.isEmpty ||
          post.parents.contains(threadInfo.opPostId) ||
          _hasExternalReferences(posts, post.parents)) {
        // find posts which are replies to the OP-post
        TreeNode<Post> node = TreeNode<Post>(
          expanded: !prefs.getBool("postsCollapsed")!,
          data: post,
          id: post.id,
          children: post.id != threadInfo.opPostId
              ? _attachChildren(post.id, posts)
              : [],
        );
        _roots.add(node);
      }
    }
    debugPrint(
        'createTreeModel() executed in ${stopwatch.elapsedMilliseconds}');
  }

  /// Called recursively to connect post children.
  List<TreeNode<Post>> _attachChildren(int? id, List<Post> posts) {
    var childrenToAdd = <TreeNode<Post>>[];
    // find all posts that are replying to this one
    Iterable<Post> childsFound =
        posts.where((post) => post.parents.contains(id));
    for (var post in childsFound) {
      // add replies to them too
      childrenToAdd.add(TreeNode(
          data: post,
          children: _attachChildren(post.id, posts),
          expanded: !prefs.getBool("postsCollapsed")!));
    }
    return childrenToAdd;
  }

  /// Check if post has references to posts in other threads.
  static bool _hasExternalReferences(List<Post> posts, List<int> referenceIds) {
    // final stopwatch = Stopwatch()..start();
    for (var referenceId in referenceIds) {
      // if there are no posts with that id in current thread, then it is an external reference
      if (posts.where((post) => post.id == referenceId).isEmpty) {
        // debugPrint('_hasExternalReferences() executed in ${stopwatch.elapsed}');
        return true;
      }
    }
    // debugPrint('_hasExternalReferences() executed in ${stopwatch.elapsed}');
    return false;
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
