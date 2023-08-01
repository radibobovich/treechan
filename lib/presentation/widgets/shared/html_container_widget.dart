import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/domain/services/search_bar_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/parser.dart' as html;

import '../../../main.dart';
import '../../../utils/constants/enums.dart';
import '../../bloc/board_bloc.dart';
import '../../../domain/models/json/json.dart';
import '../../provider/tab_provider.dart';
import '../../../domain/models/tab.dart';
import '../../../domain/models/tree.dart';
import '../../../domain/services/scroll_service.dart';
import '../thread/post_widget.dart';

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
class HtmlContainer extends StatelessWidget {
  const HtmlContainer(
      {Key? key,
      required this.post,
      this.treeNode,
      this.roots,
      required this.currentTab,
      this.scrollService})
      : super(key: key);
  // data can be Post or Thread object
  final Post post;
  final TreeNode<Post>? treeNode;
  final List<TreeNode<Post>>? roots;
  final DrawerTab currentTab;

  final ScrollService? scrollService;
  @override
  Widget build(BuildContext context) {
    // Wrapped in ExcludeSemantics because of AssertError exception in debug mode
    return ExcludeSemantics(
      child: Html(
        // limit text on BoardScreen
        style: currentTab.type == TabTypes.thread
            ? {}
            : {'#': Style(maxLines: 15, textOverflow: TextOverflow.ellipsis)},
        data: post.comment,
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
              if (prefs.getBool('spoilers') == true) {
                return _SpoilerText(node: node, children: children);
              }
            } else {
              return children;
            }
          },
          "a": (node, children) {
            return GestureDetector(
              onTap: () => openLink(node, context),
              child: Text(
                // custom link color render
                style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    decoration: TextDecoration.underline,
                    // highlight current parent in the post text if
                    // there are multiple parents
                    fontWeight: (treeNode != null &&
                            post.aTagsCount > 1 &&
                            treeNode!.parent != null &&
                            node.tree.element!.text
                                .contains('>>${treeNode!.parent!.data.id}'))
                        ? FontWeight.bold
                        : FontWeight.normal),
                node.tree.element!.text,
              ),
            );
          },
        },
      ),
    );
  }

  void openLink(RenderContext node, BuildContext ccontext) {
    String url = node.tree.element!.attributes['href']!;
    String? searchTag = node.tree.element!.attributes['title'];
    // check if link points to some post in thread
    if (currentTab.type == TabTypes.thread &&
        url.contains("/${currentTab.tag}/res/${currentTab.id}.html#")) {
      // get post id placed after # symbol
      int id = int.parse(url.substring(url.indexOf("#") + 1));
      if (Tree.findNode(roots!, id) == null) {
        return;
      }
      openPostPreview(ccontext, id);

      // check if link is external relative to this thread
    } else {
      SearchBarService searchBarService =
          SearchBarService(currentTab: currentTab);
      try {
        DrawerTab newTab =
            searchBarService.parseInput(url, searchTag: searchTag);
        if (newTab.isCatalog != null) {
          if (currentTab.type == TabTypes.board) {
            ccontext
                .read<BoardBloc>()
                .add(ChangeViewBoardEvent(null, searchTag: newTab.searchTag));
          } else if (currentTab.type == TabTypes.thread) {
            ccontext.read<TabProvider>().openCatalog(
                boardTag: newTab.tag, searchTag: newTab.searchTag!);
          }
        } else {
          ccontext.read<TabProvider>().addTab(newTab);
        }
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
                node: Tree.findNode(roots!, id)!,
                roots: roots!,
                currentTab: currentTab,
                scrollService: scrollService,
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

int countATags(String text) {
  int count = 0;
  int index = 0;
  String substring = 'class="post-reply-link"';
  while (index < text.length) {
    index = text.indexOf(substring, index);
    if (index == -1) {
      break;
    }
    count++;
    index += substring.length;
  }
  return count;
}
