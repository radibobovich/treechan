import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import '../widgets/image_preview_widget.dart';
import '../services/tree_service.dart';

class ThreadScreen2 extends StatefulWidget {
  const ThreadScreen2({super.key, required this.threadId, required this.tag});
  final int threadId;
  final String tag;
  @override
  State<ThreadScreen2> createState() => _ThreadScreen2State();
}

class _ThreadScreen2State extends State<ThreadScreen2> {
  late Future<List<TreeNode<FormattedPost>>>
      roots; // List of posts which doesn't have parents
  @override
  void initState() {
    super.initState();
    //showlines = true;
    roots = formatPosts(widget.threadId, widget.tag);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Тред")),
        body: Column(children: [
          FutureBuilder<List<TreeNode<FormattedPost>>>(
              future: roots,
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  setShowLinesProperty(snapshot.data!);
                  return Flexible(
                    child: FlexibleTreeView<FormattedPost>(
                      scrollable: false,
                      indent: 16,
                      showLines: showLines,
                      nodes: snapshot.data!,
                      nodeItemBuilder: (context, node) {
                        return PostNode(
                          node: node,
                        );
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const Center(child: CircularProgressIndicator());
              })),
        ]));
  }
}

/// Represents post with expand/minimize button.
class PostNode extends StatelessWidget {
  final TreeNode<FormattedPost> node;
  const PostNode({Key? key, required this.node}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      //child: PostWidget(post: node.data),
      child: Row(
        children: [
          PostWidget(node: node),
          // node.hasNodes
          //     ? IconButton(
          //         iconSize: 12,
          //         splashRadius: 16,
          //         padding: EdgeInsets.zero,
          //         constraints: BoxConstraints.tight(const Size(30, 30)),
          //         icon: Icon(node.expanded ? Icons.remove : Icons.add),
          //         onPressed: () {
          //           node.expanded = !node.expanded;
          //         },
          //       )
          //     : SizedBox(
          //         width: node.depth == 0 ? 0 : 30,
          //         //width: 30,
          //       ),
        ],
      ),
    );
  }
}

class PostWidget extends StatelessWidget {
  // widget represents post
  final TreeNode<FormattedPost> node;
  const PostWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final FormattedPost post = node.data;
    //return Text(post!.postInfo!.num_.toString());
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostHeader(node: node),
              const Divider(
                thickness: 1,
              ),
              ImagesPreview(files: post.postInfo!.files),
              ExcludeSemantics(
                // Wrapped in ExcludeSemantics because of AssertError exception in debug mode
                child: Html(
                  data: post.postInfo!.comment,
                  style: {
                    '#': Style(
                        //margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                        )
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PostHeader extends StatelessWidget {
  const PostHeader({Key? key, required this.node}) : super(key: key);
  final TreeNode<FormattedPost> node;
  @override
  Widget build(BuildContext context) {
    FormattedPost post = node.data;
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
          Text(post.postInfo!.name!),
          const Spacer(),
          (node.depth % 16 <= 9 && node.depth % 16 != 0 || node.depth == 0)
              ? Text(post.postInfo!.date!)
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

/// changes to false when there are nodes with depth more than 16
bool showLines = true;
void setShowLinesProperty(List<TreeNode<FormattedPost>> roots) {
  for (var root in roots) {
    for (var child in root.children) {
      checkDepth(child);
    }
  }
}

void checkDepth(TreeNode<FormattedPost> node) {
  if (node.depth > 16) {
    showLines = false;
    return;
  }
  for (var element in node.children) {
    return checkDepth(element);
  }
}
