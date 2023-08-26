import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/exceptions.dart';

import '../models/json/json.dart';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:html/parser.dart' as html;

/// Handles everything related to the tree building, updating and searching.
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
  final List<TreeNode<Post>> _roots = [];

  List<TreeNode<Post>>? get getRoots => _roots;

  Future<(List<TreeNode<Post>>, Map<int, List<TreeNode<Post>>>)> getTree(
      {bool skipPostsModify = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!skipPostsModify) {
      _findPostParents();
    }
    findChildren(posts);
    var record = await compute(_createTreeModel, (posts, threadInfo, prefs))
        .timeout(const Duration(seconds: 90))
        .onError((error, stackTrace) {
      debugPrint('TimeoutException:');
      throw TreeBuilderTimeoutException('Building tree took too long.');
    });

    return record;
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
    stopwatch.stop();
  }

  /// Called at thread refresh.
  Future<Map<int, List<TreeNode<Post>>>> attachNewRoots(
      List<TreeNode<Post>> roots,
      Map<int, List<TreeNode<Post>>> plainNodes,
      List<Post> posts,
      Root threadInfo) async {
    final record = await getTree();

    final List<TreeNode<Post>> newRoots = record.$1;
    final Map<int, List<TreeNode<Post>>> newPlainNodes = record.$2;

    if (newRoots.isEmpty) return {};
    for (var newRoot in newRoots) {
      for (var parentId in newRoot.data.parents) {
        if (parentId != threadInfo.opPostId) {
          // Find nodes to attach new tree to
          final List<TreeNode<Post>> parentNodes = plainNodes[parentId] ?? [];

          /// Attach new tree to each parent node
          for (var parentNode in parentNodes) {
            /// fix depth because here we add the same root in multiple places of the tree
            /// Depth will be also increased by one in [addNode] method
            /// Also override key to avoid duplicate GlobalObjectKeys
            /// of [TreeNodeWidget] in flexible_tree_view package
            parentNode.addNode(newRoot.copyWith(
                key: parentNode.data.id.toString() + newRoot.data.id.toString(),
                newKey: true)
              ..depth = parentNode.depth);

            /// find index of a child to add it to the post children list
            int childIndex =
                posts.indexWhere((child) => child.id == newRoot.data.id);
            parentNode.data.children.add(childIndex);

            /// find index of a parent post to update his children list too
            int nodeIndex =
                posts.indexWhere((element) => element.id == parentNode.data.id);

            /// update children in [_posts]
            posts[nodeIndex].children.add(childIndex);
          }
        } else {
          roots.add(newRoot);
        }
      }

      if (newRoot.data.parents.isEmpty) {
        roots.add(newRoot);
      }
    }
    return newPlainNodes;
  }

  /// Finds first node by post id in the list of trees.
  ///
  /// Use this only if you can't access [threadService._plainNodes] map.
  /// Consider using the map if possible for O(1) complexity.
  ///
  /// Worth noting that there might be multiple nodes containing same post.
  ///
  /// Consider using [findAllNodes] instead if its important.
  static TreeNode<Post>? findNode(List<TreeNode<Post>> roots, int id) {
    final stopwatch = Stopwatch()..start();
    // for (var root in roots doesn't work for some reason)
    for (int i = 0; i < roots.length; i++) {
      if (roots[i].data.id == id) {
        debugPrint(
            'findNode() executed in ${stopwatch.elapsedMicroseconds} microseconds');
        return roots[i];
      } else if (roots[i].data.id < id) {
        final TreeNode<Post>? result = findNode(roots[i].children, id);
        if (result != null) return result;
      }

      // TreeNode<Post>? result = _findNodeInChildren(roots[i], id);
      // if (result == null) {
      //   continue;
      // }

      debugPrint(
          'findNode() executed in ${stopwatch.elapsedMicroseconds} microseconds');
      stopwatch.stop();
    }
    return null;
  }

  /// Finds all nodes by post id in the nodes of the list of trees.
  ///
  /// Use this only if you can't access [threadRepository.plainNodes] map.
  /// Consider using the map if possible for O(1) complexity.
  static List<TreeNode<Post>> findAllNodes(List<TreeNode<Post>> roots, int id) {
    final List<TreeNode<Post>> results = [];
    for (var root in roots) {
      if (root.data.id == id) {
        results.add(root);
      } else if (root.data.id < id) {
        results.addAll(findAllNodes(root.children, id));
      }
    }
    return results;
  }

  /// Walks up the tree to find the root node.
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
    stopwatch.stop();
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

/// Creates list of comment roots and map all nodes by post id.
/// This is a heavy function and defined outside the class to use in an isolate.
Future<(List<TreeNode<Post>>, Map<int, List<TreeNode<Post>>>)> _createTreeModel(
    (List<Post>, Root, SharedPreferences) record) async {
  List<Post> posts = record.$1;
  Root threadInfo = record.$2;
  SharedPreferences prefs = record.$3;

  final Map<int, List<TreeNode<Post>>> plainNodes = {};

  final Set<int> postsWithId = posts.map((post) => post.id).toSet();

  List<TreeNode<Post>>? roots = [];

  final stopwatch = Stopwatch()..start();

  /// In case of thread refresh function [_isExternalReference()] works
  /// to determine if the post replies to the old posts in the thread
  /// since at refresh we dont have previous posts list, so if it can't
  /// find it in the postIds it returns true.
  for (var post in posts) {
    if (post.parents.isEmpty ||
        post.parents.contains(threadInfo.opPostId) ||
        _isExternalReference(postsWithId, post.parents)) {
      // find posts which are replies to the OP-post
      TreeNode<Post> node = TreeNode<Post>(
        expanded: !prefs.getBool("postsCollapsed")!,
        data: post,
        children: post.id != threadInfo.opPostId
            ? _attachChildren(post, posts, prefs, plainNodes, stopwatch, 1).$1
            : [],
      );
      roots.add(node);

      /// add to plainNodes too
      if (plainNodes[post.id] == null) {
        plainNodes[post.id] = [node];
      } else {
        plainNodes[post.id]!.add(node);
      }
    }
  }
  debugPrint('createTreeModel() executed in ${stopwatch.elapsedMilliseconds}');
  stopwatch.stop();
  return (roots, plainNodes);
}

/// Called recursively to attach post children.
(List<TreeNode<Post>>, Map<int, List<TreeNode<Post>>>) _attachChildren(
    Post post,
    List<Post> posts,
    SharedPreferences prefs,
    Map<int, List<TreeNode<Post>>> plainNodes,
    Stopwatch stopwatch,
    int depth) {
  /// Kills isolate if it takes too long
  if (stopwatch.elapsedMilliseconds > 91 * 1000) {
    return (<TreeNode<Post>>[], <int, List<TreeNode<Post>>>{});
  }
  var childrenToAdd = <TreeNode<Post>>[];
  // find all posts that are replying to this one
  List<int> children = post.children;
  for (var index in children) {
    final child = posts[index];

    final node = TreeNode(

        /// Make key unique to avoid GlobalKey and
        /// GlobalObjectKey collisions due to the same root created at refresh
        /// attached in multiple places of the tree.
        key: UniqueKey().toString(),
        data: child,
        children: _attachChildren(
                child, posts, prefs, plainNodes, stopwatch, depth + 1)
            .$1,
        expanded: !prefs.getBool("postsCollapsed")!);
    childrenToAdd.add(node);

    /// add to plainNodes too
    if (plainNodes[node.data.id] == null) {
      plainNodes[node.data.id] = [node];
    } else {
      if (!plainNodes[node.data.id]!.contains(node)) {
        plainNodes[node.data.id]!.add(node);
      }
    }
  }
  return (childrenToAdd, plainNodes);
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
