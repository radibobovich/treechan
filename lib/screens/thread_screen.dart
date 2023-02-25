import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:treechan/models/thread_container.dart';
import '../models/tree_service.dart';
import 'package:treechan/models/board_json.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/go_back_widget.dart';
import 'tab_navigator.dart';
import '../widgets/post_widget.dart';

List<PostWidget> visiblePosts = List.empty(growable: true);
List<PostWidget> partiallyVisiblePosts = List.empty(growable: true);
PostWidget getFirstVisiblePost() {
  Map<PostWidget, double> posts = {};
  for (PostWidget post in visiblePosts) {
    RenderObject? obj =
        (post.key as GlobalKey).currentContext?.findRenderObject();
    RenderBox? box = obj != null ? obj as RenderBox : null;
    Offset? position = box?.localToGlobal(Offset.zero);
    double? y = position?.dy;
    if (y != null) {
      posts[post] = y;
    }
  }
  var sortedByOffset = Map.fromEntries(
      posts.entries.toList()..sort((e1, e2) => e1.value.compareTo(e2.value)));
  // for debugging
  List<String> visibleIds = [];
  for (PostWidget post in visiblePosts) {
    visibleIds.add(post.node.data.id!.toString());
  }
  if (sortedByOffset.isEmpty) {
    return partiallyVisiblePosts.first;
  }
  return sortedByOffset.keys.first;
}

Future<void> scrollToPost(PostWidget post, ScrollController scrollController,
    double initialOffset, BuildContext context) async {
  RenderObject? obj;
  RenderBox? box;
  Offset? position;
  double? currentOffset;
  Completer<void> completer = Completer<void>();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    obj = (post.key as GlobalKey).currentContext?.findRenderObject(); // null
    box = obj != null ? obj as RenderBox : null;
    position = box?.localToGlobal(Offset.zero);
    currentOffset = position?.dy;
    completer.complete();
  });
  await completer.future;
  if (currentOffset == initialOffset) {
    return;
  }
  // ignore: use_build_context_synchronously
  double screenHeight = MediaQuery.of(context).size.height;
  Timer.periodic(const Duration(milliseconds: 20), (timer) {
    if (currentOffset != null &&
        (currentOffset! < initialOffset + 20 ||
            currentOffset! > initialOffset - 20)) {
      timer.cancel();
    }
    if (currentOffset == null) {
      // https://stackoverflow.com/questions/49553402/how-to-determine-screen-height-and-width
      scrollController.animateTo(scrollController.offset + screenHeight,
          duration: const Duration(milliseconds: 50), curve: Curves.easeOut);
    } else {
      scrollController.animateTo(
          scrollController.offset + (currentOffset! - initialOffset),
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut);
      timer.cancel();
    }
    obj = (post.key as GlobalKey).currentContext?.findRenderObject();
    box = obj != null ? obj as RenderBox : null;
    position = box?.localToGlobal(Offset.zero);
    currentOffset = position?.dy;
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
            // IconButton(
            //   icon: const Icon(Icons.abc),
            //   onPressed: () {
            //     scrollController.jumpTo(8539);
            //   },
            // ),
            IconButton(
                onPressed: () async {
                  PostWidget? firstVisiblePost;
                  RenderObject? obj;
                  RenderBox? box;
                  double? initialOffset;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    firstVisiblePost = getFirstVisiblePost();
                    obj = (firstVisiblePost!.key as GlobalKey)
                        .currentContext
                        ?.findRenderObject(); // null
                    box = obj != null ? obj as RenderBox : null;
                    Offset? position = box?.localToGlobal(Offset.zero);
                    initialOffset = position?.dy;
                  });

                  await refreshThread(
                      await threadContainer, widget.threadId, widget.tag);
                  setState(() {});
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    await scrollToPost(firstVisiblePost!, scrollController,
                        initialOffset!, context);
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
                          key: node.gKey,
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
