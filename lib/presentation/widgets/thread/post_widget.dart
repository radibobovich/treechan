import 'package:flutter/material.dart';
import 'package:treechan/main.dart';
import 'package:treechan/domain/services/date_time_service.dart';
import '../../../domain/models/json/json.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:pausable_timer/pausable_timer.dart';

import '../../../domain/models/tab.dart';
import '../../../domain/services/scroll_service.dart';
import '../shared/media_preview_widget.dart';
import '../shared/html_container_widget.dart';

class PostWidget extends StatefulWidget {
  final TreeNode<Post> node;
  final List<TreeNode<Post>> roots;
  final DrawerTab currentTab;
  final ScrollService? scrollService;
  const PostWidget(
      {super.key,
      required this.node,
      required this.roots,
      required this.currentTab,
      this.scrollService});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> with TickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Color?> colorAnimation;

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    animationController.addListener(() {
      setState(() {});
    });
  }

  PausableTimer? timer;

  @override
  Widget build(BuildContext context) {
    final Post post = widget.node.data;
    colorAnimation = ColorTween(
            begin: post.isHighlighted
                ? const Color.fromARGB(255, 255, 174, 0)
                : Theme.of(context).dividerColor,
            end: Theme.of(context).dividerColor)
        .animate(animationController);

    bool firstTimeSeen = true;
    return VisibilityDetector(
      key: Key(post.id.toString()),
      onVisibilityChanged: (visibilityInfo) {
        widget.scrollService?.checkVisibility(
          widget: widget,
          visibilityInfo: visibilityInfo,
          post: post,
        );
        handleHighlight(visibilityInfo, post, firstTimeSeen);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Card(
          child: InkWell(
            onTap: () {
              widget.node.expanded = !widget.node.expanded;
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Tooltip(
                      message: "#${post.id}",
                      child: _PostHeader(node: widget.node)),
                  Divider(
                    thickness: 1,
                    color: colorAnimation.value,
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
                      treeNode: widget.node,
                      roots: widget.roots,
                      currentTab: widget.currentTab,
                      scrollService: widget.scrollService)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void handleHighlight(
      VisibilityInfo visibilityInfo, Post post, bool firstTimeSeen) {
    if (visibilityInfo.visibleFraction == 1 && post.isHighlighted) {
      if (firstTimeSeen) {
        timer = PausableTimer(const Duration(seconds: 15), () {
          debugPrint('timer finished');
          // shouldHighlight.value = false;
          animationController.forward();
        });
        timer?.start();
        firstTimeSeen = false;
      }
    } else if (visibilityInfo.visibleFraction < 1 && post.isHighlighted) {
      timer?.pause();
    }
  }
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({Key? key, required this.node}) : super(key: key);
  final TreeNode<Post> node;

  @override
  Widget build(BuildContext context) {
    Post post = node.data;
    final DateTimeService dateTimeSerivce =
        DateTimeService(timestamp: post.timestamp);

    return Padding(
      padding: node.hasNodes
          ? const EdgeInsets.fromLTRB(8, 2, 0, 0)
          : const EdgeInsets.fromLTRB(8, 2, 8, 0),
      child: Row(
        children: [
          Text(post.name,
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

// class AnimatedDivider extends StatelessWidget {
//   final Color startColor;
//   final Color endColor;
//   final double height;
//   final Duration duration;

//   const AnimatedDivider({
//     super.key,
//     required this.startColor,
//     required this.endColor,
//     this.height = 1.0,
//     this.duration = const Duration(milliseconds: 300),
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TweenAnimationBuilder<double>(
//       tween: Tween<double>(begin: 0.0, end: 1.0),
//       duration: duration,
//       builder: (context, value, child) {
//         final color = Color.lerp(startColor, endColor, value);
//         return Divider(
//           thickness: 1,
//           color: color,
//         );
//       },
//     );
//   }
// }
