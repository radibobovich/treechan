import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import '/services/thread_service.dart';
import '/board_json.dart';
import 'package:dynamic_treeview/dynamic_treeview.dart';
import 'data_model.dart';

class Tree extends StatefulWidget {
  const Tree({super.key});
  @override
  State<Tree> createState() => _TreeState();
}

class _TreeState extends State<Tree> {
  final GlobalKey<TreeViewState> _treeKey = GlobalKey<TreeViewState>();
  late Future<List<BaseData>> formattedPosts;
  @override
  void initState() {
    super.initState();
    formatPosts();
    // formatPosts().then((value) {

    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: TreeView.simple(
        key: _treeKey,
        tree: sampleTree,
        expansionIndicator: ExpansionIndicator.RightUpChevron,
        builder: (context, level, item) => Card(
          //color: colorMapper[level.clamp(0, colorMapper.length - 1)]!,
          child: ListTile(
            title: Text("Item ${item.level}-${item.key}"),
            subtitle: Text('Level $level'),
          ),
        ),
      ),
    );
  }
}

final sampleTree = TreeNode.root()
  ..addAll([
    TreeNode(key: "0A")..add(TreeNode(key: "0A1A")),
    TreeNode(key: "0C")
      ..addAll([
        TreeNode(key: "0C1A"),
        TreeNode(key: "0C1B"),
        TreeNode(key: "0C1C")
          ..addAll([
            TreeNode(key: "0C1C2A")
              ..addAll([
                TreeNode(key: "0C1C2A3A"),
                TreeNode(key: "0C1C2A3B"),
                TreeNode(key: "0C1C2A3C"),
              ]),
          ]),
      ]),
    TreeNode(key: "0D"),
    TreeNode(key: "0E"),
  ]);

class FormattedPost {
  Post? postInfo;
  List<int>? parents = List.empty(growable: true);
  FormattedPost({this.postInfo, this.parents});
}

void formatPosts() async {
  //each formatted post will have a list of its parents
  final formattedPosts = List<FormattedPost>.empty(growable: true);
  final thread = await getThread("b", 281365085);
  final opPost = thread!.posts!.first.num_;

  thread.posts?.forEach((post) {
    var parents = getParents(post, opPost);

    final formattedPost = FormattedPost(postInfo: post, parents: parents);
    formattedPosts.add(formattedPost);
  });

  Parse(formattedPosts, formattedPosts.first.postInfo!.num_);
}

void Parse(List<FormattedPost> posts, int? opPost) {
  final mainNode = TreeNode.root();
  posts.forEach((post) {
    if (post.parents!.isEmpty || post.parents!.contains(opPost)) {
      var node = TreeNode(data: post);
      if (post.postInfo?.num_ != opPost) {
        Iterable<FormattedPost> childs = posts.where((post) =>
            post.parents?.contains(node.data?.postInfo?.number) ?? false);
        childs.forEach((child) {
          node.add(TreeNode(data: child));
        });
        node.children.forEach((key, value) {});
        print("kek");
        //node = MakeTree(node, posts);
      }
      mainNode.add(node);
    }
  });
}

// Node MakeTree(Node node, List<FormattedPost> posts) {
//   List<FormattedPost> childs =
//       posts.where((post) => post.parents?.contains(node.data.postInfo.number));
//   childs.forEach((child) {
//     node.add(TreeNode(data: child));
//   });
//   // node.children.forEach((key, value) {
//   //   MakeTree(value, posts);
//   // });
//   node.
//   return node;
// }

List<int> getParents(Post post, int? opPost) {
  // extracts parent id from <a> tag of post comment.

  //take post comment
  final postCommentHtml = parse(post.comment);
  // find <a> tags which contains data-num attribute
  var aTags = postCommentHtml.getElementsByTagName("a");
  final parents = List<int>.empty(growable: true);
  for (var aTag in aTags) {
    final keys = aTag.attributes.keys;
    final values = aTag.attributes.values;
    var attrMap = new Map();
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
