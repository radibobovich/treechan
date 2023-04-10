import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:treechan/services/search_bar_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/json/json.dart';
import '../models/tree.dart';
import '../screens/tab_navigator.dart';
import '../services/scroll_service.dart';
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
      required this.currentTab,
      required this.onOpen,
      required this.onGoBack,
      this.scrollService})
      : super(key: key);
  // data can be Post or Thread object
  final dynamic post;
  final List<TreeNode<Post>>? roots;
  final DrawerTab currentTab;

  final Function onOpen;
  final Function onGoBack;
  final ScrollService? scrollService;
  @override
  State<HtmlContainer> createState() => _HtmlContainerState();
}

class _HtmlContainerState extends State<HtmlContainer> {
  @override
  Widget build(BuildContext context) {
    return Html(
      // limit text on BoardScreen
      style: widget.currentTab.type == TabTypes.thread
          ? {}
          : {'#': Style(maxLines: 15, textOverflow: TextOverflow.ellipsis)},
      data: widget.post.comment,
      customRender: {
        "span": (node, children) {
          List<String> spanClasses = node.tree.elementClasses;
          if (spanClasses.contains("unkfunc")) {
            // greentext cite
            return TextSpan(
                style:
                    const TextStyle(color: Color.fromARGB(255, 120, 153, 34)),
                text: node.tree.element!.text);
          } else if (spanClasses.contains("spoiler")) {
            return _SpoilerText(node: node, children: children);
          }
        },
        "a": (node, children) => TextSpan(
            // custom link color render
            style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
                decoration: TextDecoration.underline),
            text: node.tree.element!.text,
            recognizer: TapGestureRecognizer()..onTap = () => openLink(node)),
      },
    );
  }

  void openLink(RenderContext node) {
    String url = node.tree.element!.attributes['href']!;
    if (widget.currentTab.type == TabTypes.thread && url.contains(
        // check if link points to some post in thread
        "/${widget.currentTab.tag}/res/${widget.currentTab.id}.html#")) {
      // get post id placed after # symbol
      int id = int.parse(url.substring(url.indexOf("#") + 1));
      if (TreeService.findPost(widget.roots!, id) == null) {
        return;
      }
      openPostPreview(context, id);

      // check if link is external relative to this thread
    } else {
      SearchBarService searchBarService =
          SearchBarService(currentTab: widget.currentTab);
      try {
        DrawerTab newTab = searchBarService.parseInput(url);
        widget.onOpen(newTab);
      } catch (e) {
        tryLaunchUrl(url);
      }
    }
  }

  Future<dynamic> openPostPreview(BuildContext context, int id) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              PostWidget(
                node: TreeService.findPost(widget.roots!, id)!,
                roots: widget.roots!,
                currentTab: widget.currentTab,
                onOpen: widget.onOpen,
                onGoBack: widget.onGoBack,
                scrollService: widget.scrollService,
              )
            ]),
          ));
        });
  }

  Future<void> tryLaunchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
