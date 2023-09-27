// import 'package:flexible_tree_view/flexible_tree_view.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../domain/models/json/json.dart';
// import '../domain/models/tree.dart';

// class MyNode<T> {
//   MyNode(
//       {required this.data,
//       required this.children,
//       required this.expanded,
//       this.id});

//   Post data;
//   List<MyNode<T>> children;
//   bool expanded = true;
//   int? id;
// }

// Future<List<TreeNode<Post>>> createTreeModel2(Set data) async {
//   List<Post> posts = data.elementAt(0);
//   Root threadInfo = data.elementAt(1);
//   SharedPreferences prefs = data.elementAt(2);

//   final Set<int> postIds = posts.map((post) => post.id).toSet();

//   final stopwatch = Stopwatch()..start();

//   findChildren(posts);
//   List<MyNode<Post>>? roots = [];
//   for (var post in posts) {
//     if (post.parents.isEmpty ||
//         post.parents.contains(threadInfo.opPostId) ||
//         _hasExternalReferences(postIds, post.parents)) {
//       // find posts which are replies to the OP-post
//       MyNode<Post> node = MyNode<Post>(
//         expanded: !prefs.getBool("postsCollapsed")!,
//         data: post,
//         id: post.id,
//         children: post.id != threadInfo.opPostId
//             ? _attachChildren2(post, posts, prefs, 1)
//             : [],
//       );
//       roots.add(node);
//     }
//   }
//   debugPrint('createTreeModel() executed in ${stopwatch.elapsedMilliseconds}');
//   List<TreeNode<Post>> normalRoots = getNormalTree(roots);
//   debugPrint('getNormalTree() executed in ${stopwatch.elapsedMilliseconds}');
//   return normalRoots;
// }

// List<MyNode<Post>> _attachChildren2(
//     Post post, List<Post> posts, SharedPreferences prefs, int depth) {
//   // debugPrint('Depth: $depth, id: ${post.id}');
//   var childrenToAdd = <MyNode<Post>>[];
//   // find all posts that are replying to this one
//   // Iterable<Post> childsFound = posts.where((post) => post.parents.contains(id));
//   List<int> children = post.children;
//   for (var index in children) {
//     post = posts[index];
//     // add replies to them too
//     childrenToAdd.add(MyNode(
//         data: post,
//         children: _attachChildren2(post, posts, prefs, depth + 1),
//         expanded: !prefs.getBool("postsCollapsed")!));
//   }
//   return childrenToAdd;
// }

// List<TreeNode<Post>> getNormalTree(List<MyNode> myRoots) {
//   List<TreeNode<Post>> roots = [];
//   for (var root in myRoots) {
//     roots.add(TreeNode(
//         data: root.data, children: attachNormalChildren(root.children, 1)));
//   }
//   return roots;
// }

// List<TreeNode<Post>> attachNormalChildren(List<MyNode> children, int depth) {
//   debugPrint('Depth: $depth');
//   List<TreeNode<Post>> normalChildren = [];
//   for (var child in children) {
//     normalChildren.add(TreeNode(
//         data: child.data,
//         children: attachNormalChildren(child.children, depth + 1)));
//   }
//   return normalChildren;
// }

// /// Check if post has references to posts in other threads.
// bool _hasExternalReferences(Set<int> postIds, List<int> referenceIds) {
//   for (var referenceId in referenceIds) {
//     // if there are no posts with that id in current thread, then it is an external reference
//     if (!postIds.contains(referenceId)) {
//       return true;
//     }
//   }
//   return false;
// }
