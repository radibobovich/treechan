import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
//import 'package:mono_kit/widgets/link_text_span.dart';
import 'package:treechan/models/board_json.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:html/dom.dart' as dom;
import '../screens/thread_screen.dart';
import '../models/tree_service.dart';

/// Represents post text.
/// Extracted from PostWidget because of a large onLinkTap function.
class _StatefulBuilderWrapper extends StatefulWidget {
  final RenderContext node;
  final Widget children;
  const _StatefulBuilderWrapper(
      {Key? key, required this.node, required this.children})
      : super(key: key);

  @override
  __StatefulBuilderWrapperState createState() =>
      __StatefulBuilderWrapperState();
}

class __StatefulBuilderWrapperState extends State<_StatefulBuilderWrapper> {
  bool _spoilerVisibility = false;

  @override
  void initState() {
    _spoilerVisibility = false;
    super.initState();
  }

  void toggleVisibility() {
    setState(() {
      _spoilerVisibility = !_spoilerVisibility;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () => toggleVisibility(),
          child: _spoilerVisibility
              ? Container(
                  height: 16.5,
                  padding: EdgeInsets.zero,
                  child: widget.children,
                )
              : Text(widget.node.tree.element!.text,
                  style: TextStyle(
                      backgroundColor: Colors.grey[600],
                      color: Colors.grey[600])),
        );
      },
    );
  }
}

class HtmlContainer extends StatefulWidget {
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
  State<HtmlContainer> createState() => _HtmlContainerState();
}

class _HtmlContainerState extends State<HtmlContainer> {
  @override
  Widget build(BuildContext context) {
    return Html(
      style: widget.isCalledFromThread
          ? {}
          : {'#': Style(maxLines: 15, textOverflow: TextOverflow.ellipsis)},
      data: widget.post.comment,
      customRender: {
        "span": (node, children) {
          List<String> spanClasses = node.tree.elementClasses;
          if (spanClasses.contains("unkfunc")) {
            return TextSpan(
                style:
                    const TextStyle(color: Color.fromARGB(255, 120, 153, 34)),
                text: node.tree.element!.text);
          } else if (spanClasses.contains("spoiler")) {
            return _StatefulBuilderWrapper(node: node, children: children);
          }
        },
        "a": (node, children) => TextSpan(
            style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
                decoration: TextDecoration.underline),
            text: node.tree.element!.text,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                String url = node.tree.element!.attributes['href']!;
                if (widget.isCalledFromThread && url.contains(
                    // check if link points to some post in thread
                    "/${widget.tag}/res/${widget.threadId}.html#")) {
                  // get post id placed after # symbol
                  int id = int.parse(url.substring(url.indexOf("#") + 1));
                  if (findPost(widget.roots!, id) == null) {
                    return;
                  }
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                            child: SingleChildScrollView(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            PostWidget(
                              node: findPost(widget.roots!, id)!,
                              roots: widget.roots!,
                              threadId: widget.threadId!,
                              tag: widget.tag!,
                            )
                          ]),
                        ));
                      });

                  // check if link is to the post in other thread and maybe in other board
                } else if (url[0] == "/" && url.contains("catalog.html")) {
                  // TODO: go to catalog
                } else if (url[0] == "/" && url.contains("/res/")) {
                  String linkTag = url.substring(1, url.indexOf("/res/"));
                  int linkThreadId = int.parse(url.substring(
                      url.indexOf("/res/") + 5, url.indexOf(".html")));
                  // TODO: replace navigator.push
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) =>
                  //           ThreadScreen(threadId: linkThreadId, tag: linkTag),
                  //       // TODO: add postId to show concrete post in new page
                  //     ));
                }

                // check if it is a web link
                else if (url.substring(0, 4) == "http") {
                  // TODO: add check if it is a full link but on 2ch
                  tryLaunchUrl(url);
                  //launchUrl(Uri.parse(url));
                }
              }),
      },
      // onLinkTap: (String? url, RenderContext renderContext,
      //     Map<String, String> attributes, dom.Element? element) {
      //   if (isCalledFromThread && url!.contains(
      //       // check if link points to some post in thread
      //       "/$tag/res/$threadId.html#")) {
      //     // get post id placed after # symbol
      //     int id = int.parse(url.substring(url.indexOf("#") + 1));
      //     if (findPost(roots!, id) == null) {
      //       return;
      //     }
      //     showDialog(
      //         context: renderContext.buildContext,
      //         builder: (BuildContext context) {
      //           return Dialog(
      //               child: SingleChildScrollView(
      //             child: Column(mainAxisSize: MainAxisSize.min, children: [
      //               PostWidget(
      //                 node: findPost(roots!, id)!,
      //                 roots: roots!,
      //                 threadId: threadId!,
      //                 tag: tag!,
      //               )
      //             ]),
      //           ));
      //         });

      //     // check if link is to the post in other thread and maybe in other board
      //   } else if (url![0] == "/" && url.contains("catalog.html")) {
      //
      //   } else if (url[0] == "/" && url.contains("/res/")) {
      //     String linkTag = url.substring(1, url.indexOf("/res/"));
      //     int linkThreadId = int.parse(
      //         url.substring(url.indexOf("/res/") + 5, url.indexOf(".html")));
      //     Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) =>
      //               ThreadScreen(threadId: linkThreadId, tag: linkTag),
      //
      //         ));
      //   }

      //   // check if it is a web link
      //   else if (url.substring(0, 4) == "http") {
      //
      //     tryLaunchUrl(url);
      //     //launchUrl(Uri.parse(url));
      //   }
      // }
    );
  }
}
