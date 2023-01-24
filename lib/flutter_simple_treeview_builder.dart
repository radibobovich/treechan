import 'package:flutter/material.dart';
import 'package:treechan/screens/board_list_screen.dart';
import 'board_json.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html;
import './services/thread_service.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';

class SimpleTree3 extends StatefulWidget {
  const SimpleTree3({super.key});

  @override
  State<SimpleTree3> createState() => _SimpleTree3State();
}

class _SimpleTree3State extends State<SimpleTree3> {
  late Future<TreeNode> mainNode;
  @override
  void initState() {
    super.initState();
    mainNode = formatPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
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
                return const CircularProgressIndicator();
              })),
        ));
  }
}

class FormattedPost {
  Post? postInfo;
  List<int>? parents = List.empty(growable: true);
  FormattedPost({this.postInfo, this.parents});
}

Future<TreeNode> formatPosts() async {
  //each formatted post will have a list of its parents
  final formattedPosts = List<FormattedPost>.empty(growable: true);
  final thread = await getThread("b", 281365085);
  final opPost = thread!.posts!.first.num_;

  thread.posts?.forEach((post) {
    var parents = getParents(post, opPost);

    final formattedPost = FormattedPost(postInfo: post, parents: parents);
    formattedPosts.add(formattedPost);
  });

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
  // if (parents.isEmpty) {
  //   // if (post.num_!= opPost){
  //   //   parents.add(0);
  //   // }
  //   parents.add(0);
  // }
  return parents;
}

TreeNode buildTree(List<FormattedPost> posts, int? opPost) {
  // builds a tree using recursive algorithm
  final mainNode = TreeNode(id: 0);
  posts.forEach((post) {
    if (post.parents!.isEmpty || post.parents!.contains(opPost)) {
      var node =
          TreeNode(content: PostWidget(post: post), id: post.postInfo!.num_);
      if (post.postInfo?.num_ != opPost) {
        // Iterable<FormattedPost> childs = posts.where((post) =>
        //     post.parents?.contains(node.data?.postInfo?.number) ?? false);
        // childs.forEach((child) {
        //   node.add(TreeNode(data: child));
        // });
        // node.children.forEach((key, value) {});
        // print("kek");
        node = MakeTree(node, posts);
      }
      mainNode.children?.add(node);
    }
  });
  return mainNode;
}

TreeNode MakeTree(TreeNode node, List<FormattedPost> posts) {
  // recursive algoritm to connect childs
  Iterable<FormattedPost> childs =
      posts.where((post) => post.parents?.contains(node.id) ?? false);
  for (var child in childs) {
    node.children?.add(
        TreeNode(content: PostWidget(post: child), id: child.postInfo!.num_));
  }
  node.children?.forEach((child) {
    MakeTree(child, posts);
  });
  return node;
}

class PostWidget extends StatelessWidget {
  // widget represents post
  final FormattedPost? post;
  const PostWidget({super.key, this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Html(data: post!.postInfo!.comment)],
      ),
    );
  }
}
