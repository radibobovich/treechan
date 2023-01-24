// import 'package:flutter/material.dart';
// import 'package:treechan/screens/board_list_screen.dart';
// import 'board_json.dart';
// import 'package:html/parser.dart' as html;
// import './services/thread_service.dart';
// import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';

// class SimpleTree2 extends StatefulWidget {
//   const SimpleTree2({super.key});

//   @override
//   State<SimpleTree2> createState() => _SimpleTree2State();
// }

// class _SimpleTree2State extends State<SimpleTree2> {
//   late Future<PostNode> mainNode;
//   @override
//   void initState() {
//     super.initState();
//     mainNode = formatPosts();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(),
//         body: FutureBuilder<PostNode>(
//             future: mainNode,
//             builder: ((context, snapshot) {
//               if (snapshot.hasData) {
//                 return MyTreeView(
//                     nodes: snapshot.data?.children ?? List.empty());
//               } else if (snapshot.hasError) {
//                 return Text('${snapshot.error}');
//               }
//               return const CircularProgressIndicator();
//             })));
//   }
// }

// class FormattedPost {
//   Post? postInfo;
//   List<int>? parents = List.empty(growable: true);
//   FormattedPost({this.postInfo, this.parents});
// }

// Future<PostNode> formatPosts() async {
//   //each formatted post will have a list of its parents
//   final formattedPosts = List<FormattedPost>.empty(growable: true);
//   final thread = await getThread("b", 281365085);
//   final opPost = thread!.posts!.first.num_;

//   thread.posts?.forEach((post) {
//     var parents = getParents(post, opPost);

//     final formattedPost = FormattedPost(postInfo: post, parents: parents);
//     formattedPosts.add(formattedPost);
//   });

//   return parse(formattedPosts, formattedPosts.first.postInfo!.num_);
// }

// List<int> getParents(Post post, int? opPost) {
//   // extracts parent id from <a> tag of post comment.

//   //take post comment
//   final postCommentHtml = html.parse(post.comment);
//   // find <a> tags which contains data-num attribute
//   var aTags = postCommentHtml.getElementsByTagName("a");
//   final parents = List<int>.empty(growable: true);
//   for (var aTag in aTags) {
//     final keys = aTag.attributes.keys;
//     final values = aTag.attributes.values;
//     var attrMap = {}; // map
//     for (int i = 0; i < keys.length; i++) {
//       // create key-value pairs for attributes
//       attrMap[keys.elementAt(i)] = values.elementAt(i);
//     }
//     //take data-num attribute, it points to a parent post
//     if (attrMap.containsKey('data-num')) {
//       var parent = int.parse(attrMap['data-num']);
//       parents.add(parent);
//     }
//   }
//   // if (parents.isEmpty) {
//   //   // if (post.num_!= opPost){
//   //   //   parents.add(0);
//   //   // }
//   //   parents.add(0);
//   // }
//   return parents;
// }

// class MyTreeView extends TreeView {
//   @override
//   final List<PostNode> nodes;
//   // maybe broken and maybe need to rewrite copyTreeNodes
//   MyTreeView(
//       {super.indent,
//       super.iconSize,
//       super.treeController,
//       super.key,
//       required this.nodes})
//       : super(nodes: nodes);
// }

// class PostNode extends TreeNode {
//   final int? id;
//   @override
//   List<PostNode> children;
//   @override
//   final Widget content;
//   PostNode({
//     super.key,
//     this.children = const [],
//     Widget? content,
//     this.id,
//   }) : content = content ?? Container(width: 0, height: 0) {
//     // avoid fixed length of const list
//     if (children.isNotEmpty) {
//       this.children = children;
//     } else {
//       this.children = List.empty(growable: true);
//     }
//   }
// }

// PostNode parse(List<FormattedPost> posts, int? opPost) {
//   final mainNode = PostNode(id: 0);
//   posts.forEach((post) {
//     if (post.parents!.isEmpty || post.parents!.contains(opPost)) {
//       var node =
//           PostNode(content: PostWidget(post: post), id: post.postInfo!.num_);
//       if (post.postInfo?.num_ != opPost) {
//         // Iterable<FormattedPost> childs = posts.where((post) =>
//         //     post.parents?.contains(node.data?.postInfo?.number) ?? false);
//         // childs.forEach((child) {
//         //   node.add(TreeNode(data: child));
//         // });
//         // node.children.forEach((key, value) {});
//         // print("kek");
//         node = MakeTree(node, posts);
//       }
//       mainNode.children.add(node);
//     }
//   });
//   return mainNode;
// }

// PostNode MakeTree(PostNode node, List<FormattedPost> posts) {
//   Iterable<FormattedPost> childs =
//       posts.where((post) => post.parents?.contains(node.id) ?? false);
//   for (var child in childs) {
//     node.children.add(
//         PostNode(content: PostWidget(post: child), id: child.postInfo!.num_));
//   }
//   node.children.forEach((child) {
//     MakeTree(child, posts);
//   });
//   return node;
// }

// class PostWidget extends StatelessWidget {
//   final FormattedPost? post;
//   const PostWidget({super.key, this.post});

//   @override
//   Widget build(BuildContext context) {
//     return Text(post!.postInfo!.num_.toString());
//   }
// }
