import 'package:flutter/material.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import '../widgets/image_preview_widget.dart';
import '../widgets/html_container_widget.dart';
import '../services/tree_service.dart';
import 'package:treechan/board_json.dart';
import 'package:url_launcher/url_launcher.dart';

/// changes to false when there are nodes with depth more than 16
bool showLines = true;
int globalThreadId = 0;
String globalTag = '';

class ThreadScreen2 extends StatefulWidget {
  const ThreadScreen2({super.key, required this.threadId, required this.tag});
  final int threadId;
  final String tag;
  @override
  State<ThreadScreen2> createState() => _ThreadScreen2State();
}

class _ThreadScreen2State extends State<ThreadScreen2> {
  late Future<List<TreeNode<Post>>>
      roots; // List of posts which doesn't have parents
  @override
  void initState() {
    super.initState();
    showLines = true;
    roots = formatPosts(widget.threadId, widget.tag);
    globalThreadId = widget.threadId;
    globalTag = widget.tag;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Тред")),
        body: Column(children: [
          Expanded(
            child: FutureBuilder<List<TreeNode<Post>>>(
                future: roots,
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    setShowLinesProperty(snapshot.data!);
                    return FlexibleTreeView<Post>(
                      scrollable: false,
                      indent: 16,
                      showLines: showLines,
                      nodes: snapshot.data!,
                      nodeItemBuilder: (context, node) {
                        return PostNode(node: node, roots: snapshot.data!);
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
}

/// Represents post with expand/minimize button.
class PostNode extends StatelessWidget {
  final TreeNode<Post> node;
  final List<TreeNode<Post>> roots;
  const PostNode({Key? key, required this.node, required this.roots})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      //child: PostWidget(post: node.data),
      child: PostWidget(node: node, roots: roots),
    );
  }
}

class PostWidget extends StatelessWidget {
  // widget represents post
  final TreeNode<Post> node;
  final List<TreeNode<Post>> roots;
  const PostWidget({super.key, required this.node, required this.roots});

  @override
  Widget build(BuildContext context) {
    final Post post = node.data;
    //return Text(post!.postInfo!.num_.toString());
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostHeader(node: node),
            const Divider(
              thickness: 1,
            ),
            ImagesPreview(files: post.files),
            ExcludeSemantics(
              // Wrapped in ExcludeSemantics because of AssertError exception in debug mode
              child: HtmlContainer(
                  post: post,
                  roots: roots,
                  isCalledFromThread: true,
                  threadId: globalThreadId.toString(),
                  tag: globalTag),
            )
          ],
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

void setShowLinesProperty(List<TreeNode<Post>> roots) {
  for (var root in roots) {
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
