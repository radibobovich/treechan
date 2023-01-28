import 'package:flutter/material.dart';
import '/board_json.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html;
import '/services/thread_service.dart';
//import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
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
                  return Flexible(
                    child: FlexibleTreeView<FormattedPost>(
                      indent: 8,
                      showLines: true,
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
          node.hasNodes
              ? IconButton(
                  iconSize: 12,
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(const Size(30, 30)),
                  icon: Icon(node.expanded ? Icons.remove : Icons.add),
                  onPressed: () {
                    node.expanded = !node.expanded;
                  },
                )
              : const SizedBox(
                  width: 12,
                ),
          PostWidget(post: node.data),
        ],
      ),
    );
  }
}

class PostWidget extends StatelessWidget {
  // widget represents post
  final FormattedPost post;
  const PostWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    //return Text(post!.postInfo!.num_.toString());
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: PostHeader(post: post),
              ),
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
  const PostHeader({Key? key, required this.post}) : super(key: key);
  final FormattedPost? post;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(post!.postInfo!.name!),
        const Spacer(),
        Text(post!.postInfo!.date!),
      ],
    );
  }
}
