import 'thread_service.dart';
import 'package:treechan/board_json.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:html/parser.dart' as html;

class FormattedPost {
  Post? postInfo;
  List<int>? parents = List.empty(growable: true);
  FormattedPost({this.postInfo, this.parents});
}

/// Add a list of parents to each post and runs createTreeModel.
Future<List<TreeNode<FormattedPost>>> formatPosts(
    int threadId, String tag) async {
  final formattedPosts = List<FormattedPost>.empty(growable: true);
  final thread = await getThread(tag, threadId);
  final opPost = thread!.posts!.first.num_;

  for (var post in thread.posts!) {
    var parents = getParents(post, opPost);

    final formattedPost = FormattedPost(postInfo: post, parents: parents);
    formattedPosts.add(formattedPost);
  }

  return createTreeModel(formattedPosts, formattedPosts.first.postInfo!.num_);
}

/// extracts parent id from <a> tag of post comment.
List<int> getParents(Post post, int? opPost) {
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
List<TreeNode<FormattedPost>> createTreeModel(
    List<FormattedPost> posts, int? opPost) {
  // List of posts which doesn't have parents
  final roots = List<TreeNode<FormattedPost>>.empty(growable: true);
  for (var post in posts) {
    if (post.parents!.isEmpty || post.parents!.contains(opPost)) {
      // find posts which are replies to the OP-post
      var node = TreeNode<FormattedPost>(
          data: post,
          id: post.postInfo!.num_,
          children: post.postInfo?.num_ != opPost
              ? attachChilds(post.postInfo!.num_, posts)
              : [],
          expanded: true);
      roots.add(node);
    }
  }
  return roots;
}

/// Called recursively to connect post childs.
List<TreeNode<FormattedPost>> attachChilds(int? id, List<FormattedPost> posts) {
  var childrenToAdd = <TreeNode<FormattedPost>>[];
  // find all posts that are replying to this one
  Iterable<FormattedPost> childsFound =
      posts.where((post) => post.parents?.contains(id) ?? false);
  for (var post in childsFound) {
    // add replies to them too
    childrenToAdd.add(TreeNode(
        data: post,
        children: attachChilds(post.postInfo!.num_, posts),
        expanded: true));
  }
  return childrenToAdd;
}
