import '../services/thread_service.dart';
import 'package:treechan/models/board_json.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:html/parser.dart' as html;
import 'thread_container.dart';

/// Add a list of parents to each post and runs createTreeModel.
Future<ThreadContainer> getThreadContainer(int threadId, String tag,
    {bool isRefresh = false, int maxNum = 0}) async {
  final threadContainer = await getThreadRawData(tag, threadId,
      isRefresh: isRefresh, maxNum: maxNum);

  if (threadContainer.posts != null) {
    for (var post in threadContainer.posts!) {
      post.parents = getPostParents(post);
    }
    threadContainer.roots = createTreeModel(
        threadContainer.posts!, threadContainer.threadInfo.opPostId);
  }
  return threadContainer;
}

/// extracts parent id from <a> tag of post comment.
List<int> getPostParents(Post post) {
  //take post comment
  final postCommentHtml = html.parse(post.comment);
  // find <a> tags which contains data-num attribute
  var aTags = postCommentHtml.getElementsByTagName("a");
  final parents = List<int>.empty(growable: true);
  for (var aTag in aTags) {
    final keys = aTag.attributes.keys;
    final values = aTag.attributes.values;
    var attrMap = {}; // map
    for (int i = 0; i < keys.length; i++) {
      // create key-value pairs for attributes
      attrMap[keys.elementAt(i)] = values.elementAt(i);
    }
    //take data-num attribute, it points to a parent post
    if (attrMap.containsKey('data-num')) {
      var parent = int.parse(attrMap['data-num']);
      parents.add(parent);
    }
  }
  return parents;
}

/// Creates a list of root trees and connects childs to each.
List<TreeNode<Post>> createTreeModel(List<Post> posts, int? opPost) {
  // List of posts which doesn't have parents
  final roots = List<TreeNode<Post>>.empty(growable: true);
  for (var post in posts) {
    if (post.parents.isEmpty ||
        post.parents.contains(opPost) ||
        hasExternalReferences(posts, post.parents)) {
      // find posts which are replies to the OP-post
      var node = TreeNode<Post>(
          data: post,
          id: post.id,
          children: post.id != opPost ? attachChilds(post.id, posts) : [],
          expanded: true);
      roots.add(node);
    }
  }
  return roots;
}

/// Called recursively to connect post childs.
List<TreeNode<Post>> attachChilds(int? id, List<Post> posts) {
  var childrenToAdd = <TreeNode<Post>>[];
  // find all posts that are replying to this one
  Iterable<Post> childsFound = posts.where((post) => post.parents.contains(id));
  for (var post in childsFound) {
    // add replies to them too
    childrenToAdd.add(TreeNode(
        data: post, children: attachChilds(post.id, posts), expanded: true));
  }
  return childrenToAdd;
}

/// Check if post has references to posts in other threads.
bool hasExternalReferences(List<Post> posts, List<int> referenceIds) {
  for (var referenceId in referenceIds) {
    // if there are no posts with that id in current thread, then it is an external reference
    if (posts.where((post) => post.id == referenceId).isEmpty) {
      return true;
    }
  }
  return false;
}

/// Finds post by id in the list of trees.
TreeNode<Post>? findPost(List<TreeNode<Post>> roots, int id) {
  // for (var root in roots doesn't work for some reason)
  for (int i = 0; i < roots.length; i++) {
    if (roots[i].data.id == id) {
      return roots[i];
    }

    var result = findPostInChildren(roots[i], id);
    if (result == null) {
      continue;
    }
    return result;
  }
  return null;
}

TreeNode<Post>? findPostInChildren(TreeNode<Post> node, int id) {
  // for (var child in node.children) doesn't work for some reason
  for (int i = 0; i < node.children.length; i++) {
    if (node.children[i].data.id == id) {
      return node.children[i];
    }
    var result = findPostInChildren(node.children[i], id);
    if (result == null) {
      continue;
    }
    return result;
  }
  return null;
}
