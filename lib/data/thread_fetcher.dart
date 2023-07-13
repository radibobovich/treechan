import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/exceptions.dart';
import 'package:http/http.dart' as http;

import '../domain/models/json/root_json.dart';

class ThreadFetcher {
  ThreadFetcher(
      {required this.boardTag,
      required this.threadId,
      required this.threadInfo});

  final String boardTag;
  final int threadId;
  final Root threadInfo;

  Future<http.Response> getThreadResponse({bool isRefresh = false}) async {
    String url;
    http.Response response;
    final prefs = await SharedPreferences.getInstance();
    if (kDebugMode &&
        (const String.fromEnvironment('thread') == 'true' ||
            prefs.getBool('test') == true) &&
        threadId == 282647314 &&
        boardTag == 'b') {
      String jsonString = await rootBundle.loadString(
          isRefresh ? 'assets/new_posts.json' : 'assets/thread.json');
      response = http.Response(jsonString, 200, headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
      });
    } else {
      // normal behavior
      url = (isRefresh)
          ? "https://2ch.hk/api/mobile/v2/after/$boardTag/$threadId/${threadInfo.maxNum! + 1}"
          : "https://2ch.hk/$boardTag/res/${threadId.toString()}.json";
      try {
        response = await http.get(Uri.parse(url));
      } on SocketException {
        throw NoConnectionException('Check your internet connection.');
      }
    }
    if (response.statusCode == 200) {
      return response;
    } else if (response.statusCode == 404) {
      throw ThreadNotFoundException(
          message: "404 ", tag: boardTag, id: threadId);
    } else {
      throw Exception(
          "Failed to load thread $boardTag/$threadId. Status code: ${response.statusCode}");
    }
  }
}
