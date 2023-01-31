import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:treechan/board_json.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:html/dom.dart' as dom;
import '../screens/thread_screen.dart';

class HtmlContainer extends StatelessWidget {
  const HtmlContainer(
      {Key? key,
      required this.post,
      this.roots,
      this.tag,
      this.threadId,
      required this.isCalledFromThread})
      : super(key: key);

  final dynamic post;
  final List<TreeNode<Post>>? roots;
  final String? tag;
  final String? threadId;
  final bool isCalledFromThread;
  @override
  Widget build(BuildContext context) {
    return Html(
        style: isCalledFromThread
            ? {}
            : {'#': Style(maxLines: 15, textOverflow: TextOverflow.ellipsis)},
        data: post.comment,
        onLinkTap: (String? url, RenderContext renderContext,
            Map<String, String> attributes, dom.Element? element) {
          if (isCalledFromThread && url!.contains(
              // check if link points to some post in thread
              "/$tag/res/$threadId.html#")) {
            // get post id placed after # symbol
            int id = int.parse(url.substring(url.indexOf("#") + 1));
            if (findPost(roots!, id) == null) {
              return;
            }
            showDialog(
                context: renderContext.buildContext,
                builder: (BuildContext context) {
                  return Dialog(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    PostWidget(node: findPost(roots!, id)!, roots: roots!)
                  ]));
                });

            // check if link is to the post in other thread and maybe in other board
          } else if (url![0] == "/" && url.contains("catalog.html")) {
            // TODO: go to catalog
          } else if (url[0] == "/" && url.contains("/res/")) {
            String tag = url.substring(1, url.indexOf("/res/"));
            int threadId = int.parse(
                url.substring(url.indexOf("/res/") + 5, url.indexOf(".html")));
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ThreadScreen2(threadId: threadId, tag: tag),
                  // TODO: add postId to show concrete post in new page
                ));
          }

          // check if it is a web link
          else if (url.substring(0, 4) == "http") {
            // TODO: add check if it is a full link but on 2ch
            tryLaunchUrl(url);
            //launchUrl(Uri.parse(url));
          }
        });
  }
}

/// Finds post by id in the list of trees.
TreeNode<Post>? findPost(List<TreeNode<Post>> roots, int id) {
  // for (var root in roots doesn't work for some reason)
  for (int i = 0; i < roots.length; i++) {
    if (roots[i].data.num_ == id) {
      return roots[i];
    }

    var result = findPostInChildren(roots[i], id);
    if (result == null) {
      continue;
    }
    return result;
  }
  return null;
}

TreeNode<Post>? findPostInChildren(TreeNode<Post> node, int id) {
  // for (var child in node.children) doesn't work for some reason
  for (int i = 0; i < node.children.length; i++) {
    if (node.children[i].data.num_ == id) {
      return node.children[i];
    }
    var result = findPostInChildren(node.children[i], id);
    if (result == null) {
      continue;
    }
    return result;
  }
  return null;
}
