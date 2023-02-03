import 'package:flutter/material.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:treechan/models/thread_container.dart';
import '../widgets/image_preview_widget.dart';
import '../widgets/html_container_widget.dart';
import '../models/tree_service.dart';
import 'package:treechan/models/board_json.dart';
import 'package:url_launcher/url_launcher.dart';

/// changes to false when there are nodes with depth more than 16

class ThreadScreen extends StatefulWidget {
  const ThreadScreen({super.key, required this.threadId, required this.tag});
  final int threadId;
  final String tag;
  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  late Future<ThreadContainer> threadContainer;
  bool showLines = true; // List of posts which doesn't have parents
  @override
  void initState() {
    super.initState();
    showLines = true;
    threadContainer = getThreadContainer(widget.threadId, widget.tag);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Тред"),
          actions: [
            IconButton(
                onPressed: () async {
                  threadContainer = refreshThread(await threadContainer);
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
                      nodes: snapshot.data!.roots!,
                      nodeItemBuilder: (context, node) {
                        return PostWidget(
                          node: node,
                          roots: snapshot.data!.roots!,
                          threadId: snapshot.data!.threadInfo.opPostId!,
                          tag: snapshot.data!.threadInfo.board!.id!,
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

  Future<ThreadContainer> refreshThread(ThreadContainer threadContainer) async {
    //int opPost = threadData.roots!.first.data.num_!;
    int opPost = threadContainer.threadInfo.opPostId!;
    // download posts which are not presented in current roots
    var newThreadContainer = await getThreadContainer(
        widget.threadId, widget.tag,
        isRefresh: true, maxNum: (threadContainer.threadInfo.maxNum!));
    if (newThreadContainer.roots!.isEmpty) return threadContainer;
    for (var root in newThreadContainer.roots!) {
      for (var parentId in root.data.parents) {
        // connect downloaded roots to its old parents
        if (parentId != opPost) {
          findPost(threadContainer.roots!, parentId)!.addNode(root);
        } else {
          // add replies to op-post without indent
          threadContainer.roots!.add(root);
        }
      }
      if (root.data.parents.isEmpty) {
        threadContainer.roots!.add(root);
      }
    }
    threadContainer.threadInfo.maxNum = newThreadContainer.threadInfo.maxNum;
    return threadContainer;
  }

  void setShowLinesProperty(List<TreeNode<Post>>? roots) {
    for (var root in roots!) {
      for (var child in root.children) {
        checkDepth(child);
      }
    }
  }

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

class PostWidget extends StatelessWidget {
  // widget represents post
  final TreeNode<Post> node;
  final List<TreeNode<Post>> roots;
  final int threadId;
  final String tag;
  const PostWidget(
      {super.key,
      required this.node,
      required this.roots,
      required this.threadId,
      required this.tag});

  @override
  Widget build(BuildContext context) {
    final Post post = node.data;
    //return Text(post!.postInfo!.num_.toString());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tooltip(message: "#${post.id}", child: PostHeader(node: node)),
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
                    roots: roots,
                    isCalledFromThread: true,
                    threadId: threadId,
                    tag: tag),
              )
            ],
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
    // if (node.depth > 16) {
    //   // prevent lines overlapping posts
    //   showlines = false;

    // }
    return Padding(
      padding: node.hasNodes
          ? const EdgeInsets.fromLTRB(8, 2, 0, 0)
          : const EdgeInsets.fromLTRB(8, 2, 8, 0),
      child: Row(
        children: [
          Text(post.name!),
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
