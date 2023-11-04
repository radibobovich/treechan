import 'package:dio/dio.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/domain/imageboards/imageboard_specific.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/domain/models/tab.dart';
import 'package:treechan/presentation/bloc/thread_base.dart';

class UnknownSpecific implements ImageboardSpecific {
  UnknownSpecific();

  @override
  List<String> get hostnames => ImageboardSpecific.allHostnamesList;

  @override
  List<int> imageTypes = [];

  @override
  List<int> videoTypes = [];

  @override
  Dio dio = Dio();
  @override
  Dio getDio(String boardTag, int threadId) {
    return dio;
  }

  @override
  bool isReplyLinkInCurrentTab(String url, DrawerTab currentTab) {
    throw UnimplementedError();
  }

  @override
  bool isReplyLinkToParentThreadTab(String url, IdMixin currentTab) {
    throw UnimplementedError();
  }

  @override
  linkCustomRender(RenderContext node, Widget children,
      {required BuildContext context,
      required TreeNode<Post>? treeNode,
      required Post post,
      required ThreadBase? bloc,
      required DrawerTab currentTab}) {
    throw UnimplementedError();
  }

  @override
  void handleLinkTap(RenderContext node,
      {required BuildContext context,
      ThreadBase? bloc,
      required DrawerTab currentTab,
      TreeNode<Post>? treeNode}) {
    throw UnimplementedError();
  }

  @override
  spanCustomRender(RenderContext node, Widget children,
      {required SharedPreferences prefs}) {
    throw UnimplementedError();
  }

  @override
  DrawerTab tryOpenTabFromLink(Uri parsedUrl, DrawerTab? currentTab,
      {String? searchTag}) {
    throw UnimplementedError();
  }
}
