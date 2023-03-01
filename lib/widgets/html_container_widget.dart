import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:treechan/models/board_json.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import '../screens/thread_screen.dart';
import '../deprecated/tree_service.dart';
import '../screens/tab_navigator.dart';
import '../widgets/post_widget.dart';

/// Represents greyed out text in post text.
class _SpoilerText extends StatefulWidget {
  final RenderContext node;
  final Widget children;
  const _SpoilerText({Key? key, required this.node, required this.children})
      : super(key: key);

  @override
  _SpoilerTextState createState() => _SpoilerTextState();
}

class _SpoilerTextState extends State<_SpoilerText> {
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
              ? widget.children
              : Text(
                  widget.node.tree.element!.text,
                  style: TextStyle(
                    backgroundColor: Colors.grey[600],
                    color: Colors.grey[600],
                    fontSize: 14.5,
                  ),
                ),
        );
      },
    );
  }
}

/// Represents post text.
/// Extracted from PostWidget because of a large onLinkTap function.
class HtmlContainer extends StatefulWidget {
  const HtmlContainer(
      {Key? key,
      required this.post,
      this.roots,
      this.tag,
      this.threadId,
      required this.isCalledFromThread,
      required this.onOpen,
      required this.onGoBack})
      : super(key: key);

  final dynamic post;
  final List<TreeNode<Post>>? roots;
  final String? tag;
  final int? threadId;
  final bool isCalledFromThread;
  final Function onOpen;
  final Function onGoBack;
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
            return _SpoilerText(node: node, children: children);
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
                              onOpen: widget.onOpen,
                              onGoBack: widget.onGoBack,
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
                  DrawerTab currentTab = DrawerTab(
                      type: TabTypes.thread,
                      tag: widget.tag!,
                      id: widget.threadId);
                  DrawerTab newTab = DrawerTab(
                      type: TabTypes.thread,
                      tag: linkTag,
                      id: linkThreadId,
                      prevTab: currentTab);
                  widget.onOpen(newTab);
                  // TODO: add postId to show concrete post in new page
                }

                // check if it is a web link
                else if (url.substring(0, 4) == "http") {
                  // TODO: add check if it is a full link but on 2ch
                  tryLaunchUrl(url);
                  //launchUrl(Uri.parse(url));
                }
              }),
      },
    );
  }
}
