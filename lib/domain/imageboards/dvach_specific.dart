import 'package:dio/dio.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/domain/imageboards/imageboard_specific.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/domain/models/tab.dart';
import 'package:treechan/exceptions.dart';
import 'package:treechan/presentation/bloc/thread_base.dart';
import 'package:treechan/presentation/widgets/shared/html_container_widget.dart';
import 'package:treechan/utils/constants/enums.dart';

class DvachSpecific implements ImageboardSpecific {
  // DvachSpecific({required this.hostnames});
  @override
  List<String> get hostnames =>
      ImageboardSpecific.allHostnamesMap[Imageboard.dvach]!;

  @override
  List<int> imageTypes = [0, 1, 2, 4, 9];

  @override
  List<int> videoTypes = [6, 10];
  @override
  Dio dio = Dio();

  @override
  Dio getDio(String boardTag, int threadId) {
    if (dio.interceptors.length > 1) return dio;
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          if (response.statusCode != null) {
            debugPrint('onResponse: statusCode is ${response.statusCode}');
            switch (response.statusCode) {
              case 200:
                {
                  if (response.redirects.isEmpty) break;
                  final String origin =
                      response.redirects.first.location.origin;
                  final String redirectPath =
                      response.redirects.last.location.path;
                  debugPrint('''
ThreadRemoteLoader: got a redirect. Throwing ArchiveRedirectException, redirect
path is ${origin + redirectPath}''');
                  throw ArchiveRedirectException(
                    requestOptions: response.requestOptions,
                    baseUrl: origin,
                    redirectPath: redirectPath,
                  );
                }
            }
          }
          handler.next(response);
        },
        onError: (e, handler) {
          if (e.response?.statusCode != null) {
            switch (e.response!.statusCode) {
              case 404:
                throw ThreadNotFoundException(
                  message: "404",
                  tag: boardTag,
                  id: threadId,
                  requestOptions: e.requestOptions,
                );
            }

            // _onThreadLoadResponseError(response.statusCode!, boardTag, threadId);
          } else {
            handler.next(e);
          }
        },
      ),
    );
    return dio;
  }

  @override
  linkCustomRender(
    RenderContext node,
    Widget children, {
    required BuildContext context,
    required TreeNode<Post>? treeNode,
    required Post post,
    required ThreadBase? bloc,
    required DrawerTab currentTab,
  }) {
    return GestureDetector(
      onTap: () => handleLinkTap(node,
          context: context,
          bloc: bloc,
          currentTab: currentTab,
          treeNode: treeNode),
      child: Text(
        // custom link color render
        style: TextStyle(
            color: Theme.of(context).secondaryHeaderColor,
            decoration: TextDecoration.underline,
            // highlight current parent in the post text if
            // there are multiple parents
            fontWeight: (treeNode != null &&
                    post.aTagsCount > 1 &&
                    treeNode.parent != null &&
                    node.tree.element!.text
                        .contains('>>${treeNode.parent!.data.id}'))
                ? FontWeight.bold
                : FontWeight.normal),
        node.tree.element!.text,
      ),
    );
  }

  @override
  void handleLinkTap(
    RenderContext node, {
    required BuildContext context,
    ThreadBase? bloc,
    required DrawerTab currentTab,
    TreeNode<Post>? treeNode,
  }) {
    /// Navigator thread links often look like this:
    /// <a class="hashlink" href="/pr/catalog.html" title="android">Android </a>
    String url = node.tree.element!.attributes['href']!;
    String? searchTag = node.tree.element!.attributes['title'];
    // check if link points to some post in thread
    if (currentTab is! BoardTab &&
        (isReplyLinkInCurrentTab(url, currentTab) ||
            isReplyLinkToParentThreadTab(url, currentTab as IdMixin))) {
      // get post id placed after # symbol
      int id = int.parse(url.substring(url.indexOf("#") + 1));

      /// bloc is not null because link is opened not from [BoardTab]
      openPostPreview(
        context,
        id,
        bloc!,
        currentTab: currentTab,
        treeNode: treeNode!,
      );

      // check if link is external relative to this thread
    } else {
      handleExternalLink(
        url,
        searchTag,
        context: context,
        currentTab: currentTab,
      );
    }
  }

  @override
  spanCustomRender(RenderContext node, Widget children,
      {required SharedPreferences prefs}) {
    List<String> spanClasses = node.tree.elementClasses;
    if (spanClasses.contains("unkfunc")) {
      // greentext cite
      return TextSpan(
          style: const TextStyle(color: Color.fromARGB(255, 120, 153, 34)),
          text: node.tree.element!.text);
    } else if (spanClasses.contains("spoiler")) {
      if (prefs.getBool('spoilers') == true) {
        return SpoilerText(node: node, children: children);
      }
    } else if (spanClasses.contains("s")) {
      return TextSpan(
          text: node.tree.element!.text,
          style: const TextStyle(decoration: TextDecoration.lineThrough));
    } else {
      return children;
    }
  }

  @override
  bool isReplyLinkInCurrentTab(String url, DrawerTab currentTab) {
    if (currentTab is! ThreadTab) return false;
    return url.contains("/${currentTab.tag}/res/${currentTab.id}.html#");
  }

  @override
  bool isReplyLinkToParentThreadTab(String url, IdMixin currentTab) {
    if (currentTab is! BranchTab) return false;

    IdMixin tab = currentTab;

    /// go to threadTab parent (branch can be opened from previous branch
    /// so we can't just use tab.prevTab)
    while (tab is! ThreadTab) {
      tab = tab.prevTab as IdMixin;
    }

    return url.contains("/${tab.tag}/res/${tab.id}.html#");
  }

  @override
  DrawerTab tryOpenTabFromLink(Uri parsedUrl, DrawerTab? currentTab,
      {String? searchTag}) {
    late DrawerTab newTab;
    if (parsedUrl.pathSegments.isNotEmpty) {
      newTab = BoardTab(
          imageboard: Imageboard.dvach,
          tag: parsedUrl.pathSegments[0],
          prevTab: currentTab ?? boardListTab);
      // find and remove empty segments
      final cleanSegments = <String>[];
      cleanSegments.addAll(parsedUrl.pathSegments);
      // remove empty segments
      cleanSegments.removeWhere((element) => element == "");
      if (cleanSegments.length > 1) {
        if (cleanSegments[1] == "res" && cleanSegments.length == 3) {
          // split is used to remove the .html extension
          newTab = ThreadTab(
              imageboard: Imageboard.dvach,
              tag: parsedUrl.pathSegments[0],
              prevTab: currentTab ?? boardListTab,
              id: int.parse(cleanSegments[2].split(".").first),
              name: null);
        } else if (cleanSegments.last == "catalog.html") {
          (newTab as BoardTab).isCatalog = true;
          newTab.query = searchTag;
        } else if (cleanSegments[1] == 'arch') {
          /// e.g. a/arch/2016-02-13/res/2656447.html
          newTab = ThreadTab(
              imageboard: Imageboard.dvachArchive,
              archiveDate: cleanSegments[2],
              tag: cleanSegments[0],
              id: int.parse(cleanSegments[4].split(".").first),
              prevTab: currentTab ?? boardListTab,
              name: null);
        } else {
          newTab = ThreadTab(
              imageboard: Imageboard.dvach,
              tag: (newTab as BoardTab).tag,
              prevTab: currentTab ?? boardListTab,
              id: int.parse(cleanSegments[1].split(".")[0]),
              name: null);
        }
      }
    }
    return newTab;
  }
}
