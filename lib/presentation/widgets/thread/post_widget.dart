import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/config/themes.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/main.dart';
import 'package:treechan/domain/services/date_time_service.dart';
import 'package:treechan/presentation/bloc/thread_base.dart';
import 'package:treechan/presentation/widgets/shared/user_platform_icons.dart';
import 'package:treechan/utils/string.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:pausable_timer/pausable_timer.dart';

import '../../../domain/models/tab.dart';
import '../../../domain/services/scroll_service.dart';
import '../../bloc/branch_bloc.dart';
import '../../bloc/thread_bloc.dart';
import '../shared/media_preview_widget.dart';
import '../shared/html_container_widget.dart';
import 'action_menu_widget.dart';

class PostWidget extends StatefulWidget {
  final ThreadBase bloc;
  final TreeNode<Post> node;
  final List<TreeNode<Post>> roots;
  final DrawerTab currentTab;
  final ScrollService? scrollService;
  final bool trackVisibility;
  const PostWidget({
    super.key,
    required this.bloc,
    required this.node,
    required this.roots,
    required this.currentTab,
    this.trackVisibility = true,
    this.scrollService,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  AnimationController? animationController;
  Animation<Color?>? colorAnimation;
  @override
  bool wantKeepAlive = false;

  @override
  void initState() {
    initializeAnimationController(widget.node.data);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    initializeColorTween(widget.node.data);
    viewportHeight = MediaQuery.of(context).size.height;
    super.didChangeDependencies();
  }

  PausableTimer? timer;
  late double viewportHeight;
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final Post post = widget.node.data;
    return VisibilityDetector(
      key: Key(post.id.toString()),
      onVisibilityChanged: (visibilityInfo) {
        if (!widget.trackVisibility) return;
        widget.scrollService?.checkVisibility(
          widget: widget,
          visibilityInfo: visibilityInfo,
          post: post,
        );
        handleHighlight(visibilityInfo, post);
        if (post.isHighlighted && visibilityInfo.visibleFraction == 0) {}
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Card(
          child: InkWell(
            onTap: () async {
              widget.node.expanded = !widget.node.expanded;
              // await Future.delayed(const Duration(milliseconds: 500));
            },
            onLongPress: () {
              openActionMenu(context, widget.bloc, widget.currentTab,
                  widget.node, setState);
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PostHeader(node: widget.node),
                  !widget.node.data.hidden
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(
                              thickness: 1,
                              color: colorAnimation?.value,
                            ),
                            post.subject == ""
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text.rich(TextSpan(
                                      text: post.subject,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                                  ),
                            MediaPreview(
                                files: post.files,
                                imageboard: widget.currentTab.imageboard),
                            HtmlContainer(
                              bloc: widget.bloc,
                              post: post,
                              treeNode: widget.node,
                              currentTab: widget.currentTab,
                              scrollService: widget.scrollService,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Removes highlight after 15 seconds of a new post being seen
  void handleHighlight(VisibilityInfo visibilityInfo, Post post) {
    if (visibilityInfo.visibleFraction > 0.6 &&
        centerIsVisible(visibilityInfo) &&
        post.isHighlighted) {
      if (post.firstTimeSeen) {
        wantKeepAlive = true;
        updateKeepAlive();
        // initializeAnimationController(post);
        timer = PausableTimer(const Duration(seconds: 5), () {
          wantKeepAlive = false;
          updateKeepAlive();
          if (mounted) {
            animationController!.forward().then((value) {
              wantKeepAlive = false;
              updateKeepAlive();
            });
          }
          post.isHighlighted = false;
        });
        post.firstTimeSeen = false;
      }

      /// Start the timer if the new post first time seen or if it has been
      /// returned back to the viewport.
      timer?.start();
    } else if (post.isHighlighted && visibilityInfo.visibleFraction <= 0.6) {
      timer?.pause();
    }
  }

  void initializeAnimationController(Post post) {
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    animationController!.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void initializeColorTween(Post post) {
    colorAnimation = ColorTween(
            begin: post.isHighlighted
                ? const Color.fromARGB(255, 255, 174, 0)
                : Theme.of(context).dividerColor,
            end: Theme.of(context).dividerColor)
        .animate(animationController!);
  }

  bool centerIsVisible(VisibilityInfo visibilityInfo) {
    return visibilityInfo.visibleBounds.center.dy >= 0 &&
        visibilityInfo.visibleBounds.center.dy <= viewportHeight;
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }
}

Future<dynamic> openActionMenu(BuildContext context, ThreadBase bloc,
    DrawerTab currentTab, TreeNode<Post> node, Function setStateCallback,
    {bool calledFromEndDrawer = false}) {
  return showDialog(
      context: context,
      builder: (BuildContext bcontext) {
        if (currentTab is ThreadTab) {
          return BlocProvider.value(
            value: bloc as ThreadBloc,
            child: AlertDialog(
                contentPadding: const EdgeInsets.all(10),
                content: ActionMenu(
                  bloc: bloc,
                  currentTab: currentTab,
                  node: node,
                  setStateCallBack: setStateCallback,
                  calledFromEndDrawer: calledFromEndDrawer,
                )),
          );
        } else if (currentTab is BranchTab) {
          return BlocProvider.value(
            value: bloc as BranchBloc,
            child: AlertDialog(
                contentPadding: const EdgeInsets.all(10),
                content: ActionMenu(
                  bloc: bloc,
                  currentTab: currentTab,
                  node: node,
                  setStateCallBack: setStateCallback,
                  calledFromEndDrawer: calledFromEndDrawer,
                )),
          );
        } else {
          throw Exception(
              'Tried to open post preview with unsupported bloc type: ${currentTab.runtimeType.toString()}');
        }
      });
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
          Text(post.boardTag != 's' ? post.name : extractUserInfo(post.name),
              style: post.email == "mailto:sage"
                  ? TextStyle(color: context.colors.boldText)
                  : null),
          post.op == true
              ? const Padding(
                  padding: EdgeInsets.fromLTRB(3, 0, 0, 0),
                  child: Text(
                    'OP',
                    style: TextStyle(
                      color: Color.fromARGB(255, 120, 153, 34),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          _isEnoughSpaceForDate()
              ? Text(" ${dateTimeSerivce.getAdaptiveDate()}",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall!.color))
              : const SizedBox.shrink(),
          post.boardTag == 's'
              ? UserPlatformIcons(userName: post.name)
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

  // don't show date for deep nodes to prevent overflow.
  // but show date in 2d scroll mode no matter how deep the node is.
  bool _isEnoughSpaceForDate() {
    return (node.depth % 16 <= 9 && node.depth % 16 != 0 ||
        node.depth == 0 ||
        prefs.getBool('2dscroll')!);
  }
}
