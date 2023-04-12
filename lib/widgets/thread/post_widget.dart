import 'package:flutter/material.dart';
import 'package:treechan/main.dart';
import 'package:treechan/services/date_time_service.dart';
import '../../models/json/json.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../screens/tab_navigator.dart';
import '../../services/scroll_service.dart';
import '../shared/media_preview_widget.dart';
import '../shared/html_container_widget.dart';

class PostWidget extends StatefulWidget {
  final TreeNode<Post> node;
  final List<TreeNode<Post>> roots;
  final DrawerTab currentTab;
  final Function onOpen;
  final Function onGoBack;
  final ScrollService? scrollService;
  const PostWidget(
      {super.key,
      required this.node,
      required this.roots,
      required this.currentTab,
      required this.onOpen,
      required this.onGoBack,
      this.scrollService});

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
        widget.scrollService?.checkVisibility(
          widget: widget,
          visibilityInfo: visibilityInfo,
          post: post,
        );
      },
      child: InkWell(
        onTap: () {
          widget.node.expanded = !widget.node.expanded;
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
                      child: _PostHeader(node: widget.node)),
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
                  MediaPreview(files: post.files),
                  HtmlContainer(
                      post: post,
                      roots: widget.roots,
                      currentTab: widget.currentTab,
                      onOpen: widget.onOpen,
                      onGoBack: widget.onGoBack,
                      scrollService: widget.scrollService)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({Key? key, required this.node}) : super(key: key);
  final TreeNode<Post> node;

  @override
  Widget build(BuildContext context) {
    Post post = node.data;
    final DateTimeService dateTimeSerivce =
        DateTimeService(dateRaw: post.date!);

    return Padding(
      padding: node.hasNodes
          ? const EdgeInsets.fromLTRB(8, 2, 0, 0)
          : const EdgeInsets.fromLTRB(8, 2, 8, 0),
      child: Row(
        children: [
          Text(post.name!,
              style: post.email == "mailto:sage"
                  ? TextStyle(color: Theme.of(context).secondaryHeaderColor)
                  // : TextStyle(
                  //     color: Theme.of(context).textTheme.bodySmall!.color),
                  : null),

          // don't show date for deep nodes to prevent overflow.
          // but show date in 2d scroll mode no matter how deep the node is.

          // todo: make it human readable
          (node.depth % 16 <= 9 && node.depth % 16 != 0 ||
                  node.depth == 0 ||
                  prefs.getBool('2dscroll')!)
              // ? Text(post.date!)
              ? Text(" ${dateTimeSerivce.getAdaptiveDate()}",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall!.color))
              : const SizedBox.shrink(),
          const Spacer(),
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
                  width: 10)
        ],
      ),
    );
  }
}
