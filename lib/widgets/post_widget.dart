import 'package:flutter/material.dart';
import '../screens/thread_screen.dart';
import '../models/board_json.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../widgets/image_preview_widget.dart';
import '../widgets/html_container_widget.dart';

class PostWidget extends StatefulWidget {
  final TreeNode<Post> node;
  final List<TreeNode<Post>> roots;
  final int threadId;
  final String tag;
  final Function onOpen;
  final Function onGoBack;
  const PostWidget(
      {super.key,
      required this.node,
      required this.roots,
      required this.threadId,
      required this.tag,
      required this.onOpen,
      required this.onGoBack});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  @override
  Widget build(BuildContext context) {
    final Post post = widget.node.data;
    return VisibilityDetector(
      key: Key(post.id.toString()),
      onVisibilityChanged: (visibilityInfo) {
        if (true) {
          if (visibilityInfo.visibleFraction == 1) {
            debugPrint("Post ${post.id} is visible, key is $widget.key");
            if (!visiblePosts.contains(widget)) {
              visiblePosts.add(widget);
            }
          }
          if (visibilityInfo.visibleFraction < 1 &&
              visiblePosts.contains(widget)) {
            debugPrint("Post ${post.id} is invisible");
            visiblePosts.remove(widget);
          }
          if (visibilityInfo.visibleFraction < 1 &&
              !visiblePosts.contains(widget) &&
              !partiallyVisiblePosts.contains(widget)) {
            partiallyVisiblePosts.add(widget);
          }
          if ((visibilityInfo.visibleFraction == 1 ||
                  visibilityInfo.visibleFraction == 0) &&
              partiallyVisiblePosts.contains(widget)) {
            partiallyVisiblePosts.remove(widget);
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Tooltip(
                    message: "#${post.id}",
                    child: PostHeader(node: widget.node)),
                //Text(post.id.toString()),
                const Divider(
                  thickness: 1,
                ),
                post.subject == ""
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text.rich(TextSpan(
                          text: post.subject,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )),
                      ),
                ImagesPreview(files: post.files),
                ExcludeSemantics(
                  // Wrapped in ExcludeSemantics because of AssertError exception in debug mode
                  child: HtmlContainer(
                      post: post,
                      roots: widget.roots,
                      isCalledFromThread: true,
                      threadId: widget.threadId,
                      tag: widget.tag,
                      onOpen: widget.onOpen,
                      onGoBack: widget.onGoBack),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PostHeader extends StatelessWidget {
  const PostHeader({Key? key, required this.node}) : super(key: key);
  final TreeNode<Post> node;
  @override
  Widget build(BuildContext context) {
    Post post = node.data;
    return Padding(
      padding: node.hasNodes
          ? const EdgeInsets.fromLTRB(8, 2, 0, 0)
          : const EdgeInsets.fromLTRB(8, 2, 8, 0),
      child: Row(
        children: [
          Text(
            post.name!,
            style: post.email == "mailto:sage"
                ? TextStyle(color: Theme.of(context).secondaryHeaderColor)
                : const TextStyle(),
          ),
          const Spacer(),
          (node.depth % 16 <= 9 && node.depth % 16 != 0 || node.depth == 0)
              ? Text(post.date!)
              : const SizedBox.shrink(),
          node.hasNodes
              ? IconButton(
                  iconSize: 20,
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(const Size(20, 20)),
                  icon: Icon(
                      node.expanded ? Icons.expand_more : Icons.chevron_right),
                  onPressed: () {
                    node.expanded = !node.expanded;
                  },
                )
              : const SizedBox(
                  //width: node.depth == 0 ? 0 : 30,
                  //width: 30,
                  width: 0)
        ],
      ),
    );
  }
}
