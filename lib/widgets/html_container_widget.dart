import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:treechan/models/board_json.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:html/dom.dart' as dom;
import '../screens/thread_screen.dart';
import '../models/tree_service.dart';

/// Represents post text.
/// Extracted from PostWidget because of a large onLinkTap function.
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
  final int? threadId;
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
                      child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      PostWidget(
                        node: findPost(roots!, id)!,
                        roots: roots!,
                        threadId: threadId!,
                        tag: tag!,
                      )
                    ]),
                  ));
                });

            // check if link is to the post in other thread and maybe in other board
          } else if (url![0] == "/" && url.contains("catalog.html")) {
            // TODO: go to catalog
          } else if (url[0] == "/" && url.contains("/res/")) {
            String linkTag = url.substring(1, url.indexOf("/res/"));
            int linkThreadId = int.parse(
                url.substring(url.indexOf("/res/") + 5, url.indexOf(".html")));
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ThreadScreen(threadId: linkThreadId, tag: linkTag),
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
