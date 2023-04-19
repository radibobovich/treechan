import 'package:flutter/material.dart';

import '../../utils/constants/enums.dart';
import '../models/tab.dart';

class SearchBarService {
  SearchBarService({this.currentTab});

  late String url;
  late Uri parsedUrl;
  DrawerTab? currentTab;
  late DrawerTab newTab;
  DrawerTab parseInput(String url, {String? searchTag}) {
    List<String> allowedHosts = ["2ch.hk", "2ch.life"];
    if (url == "") {
      throw Exception("Empty url");
    }
    this.url = url;
    parsedUrl = Uri.parse(url);

    debugPrint("Got link: '$url' Parsed: ");
    for (var segment in parsedUrl.pathSegments) {
      debugPrint(segment);
    }

    if (parsedUrl.host.isNotEmpty) {
      if (!allowedHosts.contains(parsedUrl.host)) {
        throw Exception("Host not allowed");
      }
    } else if (allowedHosts.contains(parsedUrl.pathSegments[0])) {
      // fix if the user entered a link without the protocol
      parsedUrl = Uri.parse("https://$url");
      debugPrint("Fixed protocol: ");
      for (var segment in parsedUrl.pathSegments) {
        debugPrint(segment);
      }
    }

    // TODO: add arch support
    if (parsedUrl.pathSegments.isNotEmpty) {
      newTab = DrawerTab(
          type: TabTypes.board,
          tag: parsedUrl.pathSegments[0],
          prevTab: currentTab ?? boardListTab);
      // find and remove empty segments
      final cleanSegments = <String>[];
      cleanSegments.addAll(parsedUrl.pathSegments);
      // remove empty segments
      cleanSegments.removeWhere((element) => element == "");
      if (cleanSegments.length > 1) {
        if (cleanSegments[1] == "res" && cleanSegments.length == 3) {
          newTab.type = TabTypes.thread;
          // split is used to remove the .html extension
          newTab.id = int.parse(cleanSegments[2].split(".")[0]);
        } else if (cleanSegments.last == "catalog.html") {
          newTab.isCatalog = true;
          newTab.searchTag = searchTag;
        } else {
          newTab.type = TabTypes.thread;
          newTab.id = int.parse(cleanSegments[1].split(".")[0]);
        }
      }
    }
    debugPrint(newTab.type.toString());
    debugPrint(newTab.tag);
    debugPrint(newTab.id.toString());
    return newTab;
  }
}
