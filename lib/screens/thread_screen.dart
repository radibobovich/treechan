import 'package:flutter/material.dart';
import '/board_json.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html;
import '/services/thread_service.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import '../widgets/image_preview_widget.dart';

class ThreadScreen extends StatefulWidget {
  const ThreadScreen({super.key, required this.threadId, required this.tag});
  final int threadId;
  final String tag;
  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  late Future<TreeNode> mainNode;
  @override
  void initState() {
    super.initState();
    mainNode = formatPosts(widget.threadId, widget.tag);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Тред")),
        body: SingleChildScrollView(
          child: FutureBuilder<TreeNode>(
              future: mainNode,
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  return TreeView(
                      nodes: snapshot.data?.children ?? List.empty());
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const Center(child: CircularProgressIndicator());
              })),
        ));
  }
}

class FormattedPost {
  Post? postInfo;
  List<int>? parents = List.empty(growable: true);
  FormattedPost({this.postInfo, this.parents});
}

Future<TreeNode> formatPosts(int threadId, String tag) async {
  //each formatted post will have a list of its parents
  final formattedPosts = List<FormattedPost>.empty(growable: true);
  final thread = await getThread(tag, threadId);
  final opPost = thread!.posts!.first.num_;

  for (var post in thread.posts!) {
    var parents = getParents(post, opPost);

    final formattedPost = FormattedPost(postInfo: post, parents: parents);
    formattedPosts.add(formattedPost);
  }

  return buildTree(formattedPosts, formattedPosts.first.postInfo!.num_);
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

TreeNode buildTree(List<FormattedPost> posts, int? opPost) {
  // builds a tree using recursive algorithm
  final mainNode = TreeNode(id: 0);
  for (var post in posts) {
    if (post.parents!.isEmpty || post.parents!.contains(opPost)) {
      var node =
          TreeNode(content: PostWidget(post: post), id: post.postInfo!.num_);
      if (post.postInfo?.num_ != opPost) {
        node = attachChilds(node, posts);
      }
      mainNode.children?.add(node);
    }
  }
  return mainNode;
}

TreeNode attachChilds(TreeNode node, List<FormattedPost> posts) {
  // recursive algoritm to connect childs
  Iterable<FormattedPost> childs =
      posts.where((post) => post.parents?.contains(node.id) ?? false);
  for (var child in childs) {
    node.children?.add(
        TreeNode(content: PostWidget(post: child), id: child.postInfo!.num_));
  }
  node.children?.forEach((child) {
    attachChilds(child, posts);
  });
  return node;
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
              //ImagesPreview(files: post!.postInfo!.files),
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
  }
}

class PostHeader extends StatelessWidget {
  const PostHeader({
    Key? key,
    required this.post,
  }) : super(key: key);

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
