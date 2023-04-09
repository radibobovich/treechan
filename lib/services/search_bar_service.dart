import 'package:flutter/material.dart';
import 'package:treechan/screens/tab_navigator.dart';

class SearchBarService {
  SearchBarService({this.currentTab});

  late String url;
  late Uri parsedUrl;
  DrawerTab? currentTab;
  late DrawerTab newTab;
  DrawerTab parseInput(String url) {
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
      if (parsedUrl.pathSegments.length > 1) {
        if (parsedUrl.pathSegments[1] == "res" &&
            parsedUrl.pathSegments.length == 3) {
          newTab.type = TabTypes.thread;
          // split is used to remove the .html extension
          newTab.id = int.parse(parsedUrl.pathSegments[2].split(".")[0]);
        } else {
          newTab.type = TabTypes.thread;
          newTab.id = int.parse(parsedUrl.pathSegments[1].split(".")[0]);
        }
      }
    }
    debugPrint(newTab.type.toString());
    debugPrint(newTab.tag);
    debugPrint(newTab.id.toString());
    return newTab;
  }
}
