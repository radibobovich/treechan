// import 'package:flutter/material.dart';
// import 'package:treechan/config/themes.dart';
// import 'package:flexible_tree_view/flexible_tree_view.dart';
// import 'package:treechan/domain/models/core/core_models.dart';
// import 'package:visibility_detector/visibility_detector.dart';

// import '../../../domain/models/tab.dart';
// import '../../../domain/services/scroll_service.dart';
// import '../shared/media_preview_widget.dart';
// import '../shared/html_container_widget.dart';

// class PostWidgetBorderless extends StatefulWidget {
//   final TreeNode<Post> node;
//   final List<TreeNode<Post>> roots;
//   final DrawerTab currentTab;
//   final Function onOpen;
//   final Function onGoBack;
//   final ScrollService? scrollService;
//   const PostWidgetBorderless(
//       {super.key,
//       required this.node,
//       required this.roots,
//       required this.currentTab,
//       required this.onOpen,
//       required this.onGoBack,
//       this.scrollService});

//   @override
//   State<PostWidgetBorderless> createState() => _PostWidgetBorderlessState();
// }

// class _PostWidgetBorderlessState extends State<PostWidgetBorderless> {
//   @override
//   Widget build(BuildContext context) {
//     final Post post = widget.node.data;
//     return VisibilityDetector(
//       key: Key(post.id.toString()),
//       onVisibilityChanged: (visibilityInfo) {
//         widget.scrollService?.checkVisibility(
//           widget: widget,
//           visibilityInfo: visibilityInfo,
//           post: post,
//         );
//       },
//       child: InkWell(
//         onTap: () {
//           widget.node.expanded = !widget.node.expanded;
//         },
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 2),
//           child: Padding(
//             padding: const EdgeInsets.all(4.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _PostHeaderBorderless(node: widget.node),
//                 MediaPreview(files: post.files),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
//                   child: HtmlContainer(
//                     post: post,
//                     currentTab: widget.currentTab,
//                   ),
//                 ),
//                 _PostFooterBorderless(node: widget.node)
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _PostHeaderBorderless extends StatelessWidget {
//   const _PostHeaderBorderless({Key? key, required this.node}) : super(key: key);
//   final TreeNode<Post> node;
//   @override
//   Widget build(BuildContext context) {
//     Post post = node.data;
//     return Padding(
//       padding: node.hasNodes
//           ? const EdgeInsets.fromLTRB(8, 2, 0, 0)
//           : const EdgeInsets.fromLTRB(8, 2, 8, 0),
//       child: Row(
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 post.name,
//                 style: post.email == "mailto:sage"
//                     ? TextStyle(color: context.colors.boldText)
//                     : const TextStyle(
//                         color: Color.fromARGB(255, 116, 116, 116)),
//               ),
//               Text(
//                 post.date,
//                 style:
//                     const TextStyle(color: Color.fromARGB(255, 116, 116, 116)),
//               )
//             ],
//           ),
//           const Spacer(),
//           ButtonExpand(node: node)
//         ],
//       ),
//     );
//   }
// }

// class _PostFooterBorderless extends StatelessWidget {
//   const _PostFooterBorderless({required this.node});
//   final TreeNode<Post> node;
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: node.hasNodes
//           ? const EdgeInsets.fromLTRB(8, 0, 0, 0)
//           : const EdgeInsets.fromLTRB(8, 0, 8, 0),
//       child: Row(
//         children: [
//           const Text('Ответить',
//               style: TextStyle(color: Color.fromARGB(255, 116, 116, 116))),
//           const Spacer(),
//           IconButton(
//             icon: const Icon(Icons.more_vert),
//             iconSize: 18,
//             onPressed: () {},
//           )
//         ],
//       ),
//     );
//   }
// }

// class ButtonExpand extends StatelessWidget {
//   const ButtonExpand({super.key, required this.node});
//   final TreeNode node;
//   @override
//   Widget build(BuildContext context) {
//     return node.hasNodes
//         ? IconButton(
//             iconSize: 20,
//             splashRadius: 16,
//             padding: EdgeInsets.zero,
//             constraints: BoxConstraints.tight(const Size(20, 20)),
//             icon: Icon(node.expanded ? Icons.expand_more : Icons.chevron_right),
//             onPressed: () {
//               node.expanded = !node.expanded;
//             },
//           )
//         : const SizedBox(
//             //width: node.depth == 0 ? 0 : 30,
//             //width: 30,
//             width: 0);
//   }
// }
