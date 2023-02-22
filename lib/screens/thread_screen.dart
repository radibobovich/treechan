import 'package:flutter/material.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:treechan/models/thread_container.dart';
import '../models/tree_service.dart';
import 'package:treechan/models/board_json.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/go_back_widget.dart';
import 'tab_navigator.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../widgets/post_widget.dart';

List<PostWidget> visiblePosts = List.empty(growable: true);

PostWidget getFirstVisiblePost() {
  visiblePosts.sort((a, b) => a.yPos!.compareTo(b.yPos!));
  return visiblePosts.first;
}

void scrollToPost(PostWidget post, ScrollController scrollController) {
  VisibilityDetectorController.instance.notifyNow;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    RenderObject? obj =
        (post.key as GlobalKey).currentContext?.findRenderObject(); // null
    RenderBox? box = obj != null ? obj as RenderBox : null;
    Offset? position = box?.localToGlobal(Offset.zero);
    double? y = position?.dy;

    // while (y == null || y > 200) {
    //   scrollController.animateTo(scrollController.offset + 50,
    //       duration: const Duration(milliseconds: 50), curve: Curves.easeOut);
    //   obj = (post.key as GlobalKey).currentContext?.findRenderObject();
    //   box = obj != null ? obj as RenderBox : null;
    //   position = box?.localToGlobal(Offset.zero);
    //   y = position?.dy;
    // }
  });

  return;
}

class ThreadScreen extends StatefulWidget {
  const ThreadScreen(
      {super.key,
      required this.threadId,
      required this.tag,
      required this.onOpen,
      required this.onGoBack,
      required this.prevTab});
  final int threadId;
  final String tag;
  final DrawerTab prevTab;
  final Function onOpen;
  final Function onGoBack;

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late Future<ThreadContainer> threadContainer;
  final ScrollController scrollController = ScrollController();
  bool showLines = true;
  @override
  void initState() {
    super.initState();
    showLines = true;
    threadContainer = getThreadContainer(widget.threadId, widget.tag);
  }

  GlobalKey treeKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    super.build(context);
    DrawerTab currentTab = DrawerTab(
        type: TabTypes.thread,
        id: widget.threadId,
        tag: widget.tag,
        prevTab: widget.prevTab);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Тред"),
          leading:
              GoBackButton(onGoBack: widget.onGoBack, currentTab: currentTab),
          actions: [
            IconButton(
                onPressed: () async {
                  PostWidget firstVisiblePost = getFirstVisiblePost();
                  await refreshThread(
                      await threadContainer, widget.threadId, widget.tag);
                  setState(() {});
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    scrollToPost(firstVisiblePost, scrollController);
                  });

                  setShowLinesProperty((await threadContainer).roots);
                  setState(() {});
                },
                icon: const Icon(Icons.refresh))
          ],
        ),
        body: Column(children: [
          Expanded(
            child: FutureBuilder<ThreadContainer>(
                future: threadContainer,
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    setShowLinesProperty(snapshot.data!.roots);
                    return FlexibleTreeView<Post>(
                      key: treeKey,
                      scrollable: false,
                      indent: 16,
                      showLines: showLines,
                      scrollController: scrollController,
                      nodes: snapshot.data!.roots!,
                      nodeItemBuilder: (context, node) {
                        return PostWidget(
                          //key: itemKey,
                          key: GlobalKey(),
                          node: node,
                          roots: snapshot.data!.roots!,
                          threadId: snapshot.data!.threadInfo.opPostId!,
                          tag: snapshot.data!.threadInfo.board!.id!,
                          onOpen: widget.onOpen,
                          onGoBack: widget.onGoBack,
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }
                  return const Center(child: CircularProgressIndicator());
                })),
          ),
        ]));
  }

  /// Sets showLines property to false when there are nodes with depth >=16.
  void setShowLinesProperty(List<TreeNode<Post>>? roots) {
    for (var root in roots!) {
      for (var child in root.children) {
        checkDepth(child);
      }
    }
  }

  /// Called recursively.
  void checkDepth(TreeNode<Post> node) {
    if (node.depth >= 16) {
      showLines = false;
      return;
    }

    for (var element in node.children) {
      checkDepth(element);
    }
  }
}

Future<void> tryLaunchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}
