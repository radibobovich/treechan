import 'package:flutter/material.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:treechan/models/thread_container.dart';
import '../widgets/image_preview_widget.dart';
import '../widgets/html_container_widget.dart';
import '../models/tree_service.dart';
import 'package:treechan/models/board_json.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/go_back_widget.dart';
import 'tab_navigator.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:collection';

List<PostWidget> visiblePosts = List.empty(growable: true);
//List<GlobalKey> keys = List.empty(growable: true);
//Map<int, Key> visiblePosts = {};

// GlobalKey getFirstVisiblePost() {
//   var sortedById = SplayTreeMap<int, GlobalKey>.from(
//       visiblePosts, (key1, key2) => key1.compareTo(key2));
//   return sortedById.values.first;
// }
PostWidget getFirstVisiblePost() {
  PostWidget firstVisiblePost = visiblePosts.first;
  int maxId = firstVisiblePost.node.data.id!;
  for (var post in visiblePosts) {
    if (post.node.data.id! < maxId) {
      maxId = post.node.data.id!;
      firstVisiblePost = post;
    }
  }
  return firstVisiblePost;
}

// Key getFirstVisiblePost() {
//   PostWidget firstVisiblePost = visiblePosts.first;
//   int maxId = firstVisiblePost.node.data.id!;
//   for (var post in visiblePosts) {
//     if (post.node.data.id! < maxId) {
//       maxId = post.node.data.id!;
//       firstVisiblePost = post;
//     }
//   }
//   return firstVisiblePost.key!;
// }

Future<void> scrollToPost(
    PostWidget post, ScrollController scrollController) async {
  await Future<void>.delayed(const Duration(milliseconds: 2000));
  //VisibilityDetectorController.instance.notifyNow;
  while (!visiblePosts.contains(post)) {
    VisibilityDetectorController.instance.notifyNow;
    scrollController.animateTo(scrollController.offset + 50,
        duration: const Duration(milliseconds: 20), curve: Curves.easeOut);
    debugPrint(scrollController.offset.toString());
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
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

  // final GlobalKey<_ThreadScreenState> stateKey =
  //     GlobalKey<_ThreadScreenState>();
  bool showLines = true;
  @override
  void initState() {
    super.initState();
    showLines = true;
    threadContainer = getThreadContainer(widget.threadId, widget.tag);
  }

  @override
  Widget build(BuildContext context) {
    //visiblePosts.clear();
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
                  //Key firstVisiblePost = getFirstVisiblePost();

                  // WidgetsBinding.instance.addPostFrameCallback((_) {
                  //   BuildContext buildContext =
                  //       (firstVisiblePost as GlobalKey).currentContext!;

                  //   Scrollable.ensureVisible(buildContext,
                  //       duration: const Duration(milliseconds: 200),
                  //       curve: Curves.easeOut);
                  // });

                  refreshThread(
                      await threadContainer, widget.threadId, widget.tag);

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    scrollToPost(firstVisiblePost, scrollController);
                  });

                  // WidgetsBinding.instance.addPostFrameCallback((_) {
                  //   Scrollable.ensureVisible(keys[20].currentContext!,
                  //       duration: const Duration(milliseconds: 200),
                  //       curve: Curves.easeOut);
                  // });

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
                      scrollable: false,
                      indent: 16,
                      showLines: showLines,
                      scrollController: scrollController,
                      nodes: snapshot.data!.roots!,
                      nodeItemBuilder: (context, node) {
                        //debugPrint("node: ${node.data.id} is built");
                        //GlobalKey itemKey = GlobalKey();
                        //keys.add(itemKey);
                        return PostWidget(
                          //key: itemKey,
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

class PostWidget extends StatefulWidget {
  final TreeNode<Post> node;
  final List<TreeNode<Post>> roots;
  final int threadId;
  final String tag;
  final Function onOpen;
  final Function onGoBack;
  //GlobalKey? gKey;
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
  //final gKey = GlobalKey<_PostWidgetState>();
  @override
  Widget build(BuildContext context) {
    //widget.gKey = GlobalKey<_PostWidgetState>();
    final Post post = widget.node.data;
    return VisibilityDetector(
      key: Key(post.id.toString()),
      onVisibilityChanged: (visibilityInfo) {
        if (true) {
          if (visibilityInfo.visibleFraction == 1) {
            debugPrint("Post ${post.id} is visible, key is $widget.key");
            //visiblePosts[post.id!] = widget.key!;
            visiblePosts.add(widget);
          }
          if (visibilityInfo.visibleFraction == 0) {
            debugPrint("Post ${post.id} is invisible");
            //visiblePosts.remove(post.id);
            visiblePosts.remove(widget);
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

Future<void> tryLaunchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
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
