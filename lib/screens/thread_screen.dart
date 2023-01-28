import 'package:flutter/material.dart';
import '/board_json.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html;
import '/services/thread_service.dart';
//import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import '../widgets/image_preview_widget.dart';

class ThreadScreen2 extends StatefulWidget {
  const ThreadScreen2({super.key, required this.threadId, required this.tag});
  final int threadId;
  final String tag;
  @override
  State<ThreadScreen2> createState() => _ThreadScreen2State();
}

class _ThreadScreen2State extends State<ThreadScreen2> {
  late Future<List<TreeNode<FormattedPost>>>
      roots; // List of posts which doesn't have parents
  @override
  void initState() {
    super.initState();
    roots = formatPosts(widget.threadId, widget.tag);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Тред")),
        body: Column(children: [
          FutureBuilder<List<TreeNode<FormattedPost>>>(
              future: roots,
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                    child: FlexibleTreeView<FormattedPost>(
                      nodes: snapshot.data!,
                      nodeItemBuilder: (context, node) {
                        return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            //child: PostWidget(post: node.data),
                            child: Row(
                              children: [
                                node.hasNodes
                                    ? IconButton(
                                        iconSize: 12,
                                        splashRadius: 16,
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints.tight(
                                            const Size(30, 30)),
                                        icon: Icon(node.expanded
                                            ? Icons.remove
                                            : Icons.add),
                                        onPressed: () {
                                          node.expanded = !node.expanded;
                                        },
                                      )
                                    : const SizedBox(
                                        width: 12,
                                      ),
                                PostWidget(post: node.data),
                              ],
                            ));
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const Center(child: CircularProgressIndicator());
              })),
        ]));
  }
}

class FormattedPost {
  Post? postInfo;
  List<int>? parents = List.empty(growable: true);
  FormattedPost({this.postInfo, this.parents});
}

Future<List<TreeNode<FormattedPost>>> formatPosts(
    int threadId, String tag) async {
  //each formatted post will have a list of its parents
  final formattedPosts = List<FormattedPost>.empty(growable: true);
  final thread = await getThread(tag, threadId);
  final opPost = thread!.posts!.first.num_;

  for (var post in thread.posts!) {
    var parents = getParents(post, opPost);

    final formattedPost = FormattedPost(postInfo: post, parents: parents);
    // for (var parent in parents){
    //   final formattedPost = FormattedPost(postInfo: post, parents: parent);
    // }
    formattedPosts.add(formattedPost);
  }

  return createTreeModel(formattedPosts, formattedPosts.first.postInfo!.num_);
}

List<int> getParents(Post post, int? opPost) {
  // extracts parent id from <a> tag of post comment.

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

List<TreeNode<FormattedPost>> createTreeModel(
    List<FormattedPost> posts, int? opPost) {
  //final mainNode = TreeNode<FormattedPost>(data: FormattedPost(), id: 0);

  // List of posts which doesn't have parents
  final roots = List<TreeNode<FormattedPost>>.empty(growable: true);
  for (var post in posts) {
    if (post.parents!.isEmpty || post.parents!.contains(opPost)) {
      //var node = TreeNode<FormattedPost>(data: post, id: post.postInfo!.num_);
      var node = TreeNode<FormattedPost>(
          data: post,
          id: post.postInfo!.num_,
          children: post.postInfo?.num_ != opPost
              ? attachChilds(post.postInfo!.num_, posts)
              : [],
          expanded: true);
      // if (post.postInfo?.num_ != opPost) {
      //   node = attachChilds(node, posts);
      // }
      //mainNode.children?.add(node);
      roots.add(node);
    }
  }
  return roots;
}

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

class PostWidget extends StatelessWidget {
  // widget represents post
  final FormattedPost? post;
  const PostWidget({super.key, this.post});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: PostHeader(post: post),
              ),
              const Divider(
                thickness: 1,
              ),
              ImagesPreview(files: post!.postInfo!.files),
              Html(
                data: post!.postInfo!.comment,
                style: {
                  '#': Style(
                      //margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      )
                },
              )
            ],
          ),
        ),
      ),
    );
    //return Text(post!.postInfo!.num_.toString());
  }
}

class PostHeader extends StatelessWidget {
  const PostHeader({Key? key, required this.post}) : super(key: key);

  final FormattedPost? post;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(post!.postInfo!.name!),
        const Spacer(),
        Text(post!.postInfo!.date!),
      ],
    );
  }
}
