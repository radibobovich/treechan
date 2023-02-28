import '../services/thread_service.dart';
import 'package:treechan/models/board_json.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:html/parser.dart' as html;
import 'thread_container.dart';

/// Returns threadContainer with list of comment trees and other info.
Future<ThreadContainer> getThreadContainer(int threadId, String tag,
    {bool isRefresh = false, int maxNum = 0}) async {
  final threadContainer = await getThreadRawData(tag, threadId,
      isRefresh: isRefresh, maxNum: maxNum);

  if (threadContainer.posts != null) {
    for (var post in threadContainer.posts!) {
      post.parents = _getPostParents(post);
    }
    threadContainer.roots = _createTreeModel(
        threadContainer.posts!, threadContainer.threadInfo.opPostId);
  }
  return threadContainer;
}

/// Extracts parent id from <a> tag of post comment.
List<int> _getPostParents(Post post) {
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
  return parents;
}

/// Creates a list of root trees and connects childs to each.
List<TreeNode<Post>> _createTreeModel(List<Post> posts, int? opPost) {
  // List of posts which doesn't have parents
  final roots = List<TreeNode<Post>>.empty(growable: true);
  for (var post in posts) {
    if (post.parents.isEmpty ||
        post.parents.contains(opPost) ||
        _hasExternalReferences(posts, post.parents)) {
      // find posts which are replies to the OP-post
      TreeNode<Post> node = TreeNode<Post>(
          data: post,
          id: post.id,
          children: post.id != opPost ? _attachChilds(post.id, posts) : [],
          expanded: true);
      roots.add(node);
    }
  }
  return roots;
}

/// Called recursively to connect post childs.
List<TreeNode<Post>> _attachChilds(int? id, List<Post> posts) {
  var childrenToAdd = <TreeNode<Post>>[];
  // find all posts that are replying to this one
  Iterable<Post> childsFound = posts.where((post) => post.parents.contains(id));
  for (var post in childsFound) {
    // add replies to them too
    childrenToAdd.add(TreeNode(
        data: post, children: _attachChilds(post.id, posts), expanded: true));
  }
  return childrenToAdd;
}

/// Gets new posts from server and adds them to the existing threadContainer.
/// Connects new posts to their old parents.
/// Returns updated threadContainer.
Future<ThreadContainer> refreshThread(
    ThreadContainer threadContainer, int threadId, String tag) async {
  int opPost = threadContainer.threadInfo.opPostId!;
  // download posts which are not presented in current roots
  ThreadContainer newThreadContainer = await getThreadContainer(threadId, tag,
      isRefresh: true, maxNum: (threadContainer.threadInfo.maxNum!));
  if (newThreadContainer.roots!.isEmpty) return threadContainer;
  for (var root in newThreadContainer.roots!) {
    for (var parentId in root.data.parents) {
      // connect downloaded roots to its old parents
      if (parentId != opPost) {
        findPost(threadContainer.roots!, parentId)!.addNode(root);
      } else {
        // add replies to op-post without indent
        threadContainer.roots!.add(root);
      }
    }
    if (root.data.parents.isEmpty) {
      threadContainer.roots!.add(root);
    }
  }
  threadContainer.threadInfo.maxNum = newThreadContainer.threadInfo.maxNum;
  return threadContainer;
}

/// Check if post has references to posts in other threads.
bool _hasExternalReferences(List<Post> posts, List<int> referenceIds) {
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

    TreeNode<Post>? result = _findPostInChildren(roots[i], id);
    if (result == null) {
      continue;
    }
    return result;
  }
  return null;
}

/// Called recursively.
TreeNode<Post>? _findPostInChildren(TreeNode<Post> node, int id) {
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
