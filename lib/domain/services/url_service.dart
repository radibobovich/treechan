import 'package:flutter/material.dart';
import 'package:treechan/utils/constants/enums.dart';

import '../models/tab.dart';

@Deprecated('Use ImageboardSpecific.tryOpenLink() instead.')
class UrlService {
  // UrlService({this.currentTab});

  // late String url;
  // late Uri parsedUrl;
  // DrawerTab? currentTab;
  // late DrawerTab newTab;
  DrawerTab tryOpenLink(String url, DrawerTab? currentTab,
      {String? searchTag}) {
    List<String> allowedHosts = ["2ch.hk", "2ch.life"];
    if (url == "") {
      throw Exception("Empty url");
    }
    // this.url = url;
    Uri parsedUrl = Uri.parse(url);

    debugPrint("Got link: '$url' Parsed: ");
    for (var segment in parsedUrl.pathSegments) {
      debugPrint(segment);
    }

    if (parsedUrl.host.isNotEmpty) {
      if (!allowedHosts.contains(parsedUrl.host)) {
        throw Exception("Host not allowed");
      }
    } else if (allowedHosts.contains(parsedUrl.pathSegments[0])) {
      // fix if the user entered a link without a protocol
      parsedUrl = Uri.parse("https://$url");
      debugPrint("Fixed protocol: ");
      for (var segment in parsedUrl.pathSegments) {
        debugPrint(segment);
      }
    }

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
              id: int.parse(cleanSegments[2].split(".")[0]),
              name: null);
        } else if (cleanSegments.last == "catalog.html") {
          (newTab as BoardTab).isCatalog = true;
          newTab.query = searchTag;
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
