import 'package:dio/dio.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/domain/imageboards/unknown_specific.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/domain/models/tab.dart';
import 'package:treechan/presentation/bloc/thread_base.dart';
import 'package:treechan/presentation/provider/page_provider.dart';
import 'package:treechan/presentation/widgets/shared/html_container_widget.dart';
import 'package:treechan/utils/constants/enums.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dvach_specific.dart';

abstract interface class ImageboardSpecific {
  /// Hostnames should be added here while new imageboard is added
  static const Map<Imageboard, List<String>> allHostnamesMap = {
    Imageboard.dvach: ["2ch.hk", "2ch.life"],
  };

  static List<String> get allHostnamesList =>
      allHostnamesMap.values.reduce((result, value) => [...result, ...value]);

  static final DvachSpecific _dvachSpecific = DvachSpecific();
  static final UnknownSpecific _unknownSpecific = UnknownSpecific();

  abstract final List<String> hostnames;
  abstract Dio dio;

  factory ImageboardSpecific(Imageboard imageboard) {
    switch (imageboard) {
      case Imageboard.dvach:
        return _dvachSpecific;
      case Imageboard.dvachArchive:
        return _dvachSpecific;
      case Imageboard.unknown:
        return _unknownSpecific;
    }
  }

  /// Number codes for file types in post attachments
  abstract List<int> imageTypes;
  abstract List<int> videoTypes;

  /// Custom [Dio] that is specific for the imageboard.
  ///
  /// Useful when you need to set up interceptors.
  Dio getDio(String boardTag, int threadId);

  /// Renders imageboard specific styles such as greentext and spoilers.
  ///
  /// Used in [HtmlContainer].
  spanCustomRender(RenderContext node, Widget children,
      {required SharedPreferences prefs});

  /// Adds custom link behavior in [HtmlContainer] and handles its decoration.
  ///
  /// [linkCustomRender] should normally have [handleLinkTap] callback,
  /// which decides whether to call [handleExternalLink] or [openPostPreview].
  linkCustomRender(
    RenderContext node,
    Widget children, {
    required BuildContext context,
    required TreeNode<Post>? treeNode,
    required Post post,
    required ThreadBase? bloc,
    required DrawerTab currentTab,
  });

  void handleLinkTap(
    RenderContext node, {
    required BuildContext context,
    ThreadBase? bloc,
    required DrawerTab currentTab,
    TreeNode<Post>? treeNode,
  });

  /// Checks if the link refers to a post in the current tab.
  bool isReplyLinkInCurrentTab(String url, DrawerTab currentTab);

  /// Reply links at [BranchScreen] may point to a post that is not in the
  /// current branch. So we need to check if it is a reply to a post
  /// that is in the parent [ThreadScreen].
  bool isReplyLinkToParentThreadTab(String url, IdMixin currentTab);

  /// Called from [handleExternalLink] in [HtmlContainer] or
  /// from [SearchBar] when you don't know what is the imageboard and even
  /// whether it is an imageboard link.
  static tryOpenUnknownTabFromLink(String url, DrawerTab? currentTab,
          {String? searchTag}) =>
      _tryOpenUnknownTabFromLink(url, currentTab, searchTag: searchTag);

  /// Imageboard specific method for opening tabs.
  ///
  /// You must not call it directly. This method is called from
  /// tryOpenTabFromLink global function that is imageboard independent.
  DrawerTab tryOpenTabFromLink(Uri parsedUrl, DrawerTab? currentTab,
      {String? searchTag});
}

/// Imageboard independent function that parses the link and decides
/// what imageboard it leads to, then calls imageboard specific parser method.
///
/// Sometimes you can't get imageboard from the [url], for example, if
/// the [url] is a search query got from [SearchBar]. In this case
/// imageboard will be inferenced from [currentTab].
DrawerTab _tryOpenUnknownTabFromLink(String url, DrawerTab? currentTab,
    {String? searchTag}) {
  if (url == "") {
    throw Exception("Empty url");
  }
  Uri parsedUrl = Uri.parse(url);

  debugPrint("Got link: '$url' Parsed: ");
  for (var segment in parsedUrl.pathSegments) {
    debugPrint(segment);
  }

  late Imageboard imageboard;

  if (parsedUrl.host.isNotEmpty) {
    if (!ImageboardSpecific.allHostnamesList.contains(parsedUrl.host)) {
      throw Exception("Host not allowed");
    }
    imageboard = ImageboardSpecific.allHostnamesMap.entries
        .firstWhere((entry) => entry.value.contains(parsedUrl.host))
        .key;
  } else {
    if (ImageboardSpecific.allHostnamesList
        .contains(parsedUrl.pathSegments[0])) {
      // fix if the user entered a link without a protocol
      parsedUrl = Uri.parse("https://$url");

      debugPrint("Fixed protocol: ");
      for (var segment in parsedUrl.pathSegments) {
        debugPrint(segment);
      }

      imageboard = ImageboardSpecific.allHostnamesMap.entries
          .firstWhere((entry) => entry.value.contains(parsedUrl.host))
          .key;
    } else {
      /// A case when user entered board tag only or tag/id string,
      /// we have to inference the imageboard from [currentTab]
      imageboard = currentTab?.imageboard ?? boardListTab.imageboard;
    }
  }

  /// Calls imageboard specific part of the procedure
  final DrawerTab newTab = ImageboardSpecific(imageboard)
      .tryOpenTabFromLink(parsedUrl, currentTab, searchTag: searchTag);

  return newTab;
}

/// Calls when tapped link doesn't lead to any post in the thread
/// or if the link has been tapped while on [BoardScreen].
void handleExternalLink(
  String url,
  String? searchTag, {
  required BuildContext context,
  required DrawerTab currentTab,
}) {
  /// Try to parse link as board or thread, if failed, then open as web link
  try {
    final newTab = ImageboardSpecific.tryOpenUnknownTabFromLink(
      url,
      currentTab,
      searchTag: searchTag,
    );
    if (newTab is BoardTab && newTab.isCatalog == true) {
      context.read<PageProvider>().openCatalog(
          imageboard: newTab.imageboard,
          boardTag: newTab.tag,
          query: newTab.query ?? '');
    } else {
      context.read<PageProvider>().addTab(newTab);
    }
  } catch (e) {
    _tryLaunchUrl(url);
  }
}

Future<void> _tryLaunchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}
