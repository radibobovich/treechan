import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:treechan/data/thread/response_handler.dart';
import 'package:treechan/domain/models/json/json.dart';

abstract class IThreadRefresher {
  // ignore: unused_element
  Future<http.Response> _getRefreshResponse(
      String boardTag, int threadId, int lastPostId);

  Future<List<Post>> getNewPosts(
      {required String boardTag,
      required int threadId,
      required int lastPostId});
}

class ThreadRefresher implements IThreadRefresher {
  const ThreadRefresher(this.responseHandler);
  final IResponseHandler responseHandler;
  @override
  Future<http.Response> _getRefreshResponse(
    String boardTag,
    int threadId,
    int lastPostId,
  ) async {
    final String url =
        "https://2ch.hk/api/mobile/v2/after/$boardTag/$threadId/${lastPostId + 1}";

    return await responseHandler.getResponse(
        url: url, boardTag: boardTag, threadId: threadId);
  }

  @override
  Future<List<Post>> getNewPosts({
    required String boardTag,
    required int threadId,
    required int lastPostId,
  }) async {
    final http.Response response =
        await _getRefreshResponse(boardTag, threadId, lastPostId);

    debugPrint('Thread $boardTag/$threadId refreshed');
    return postListFromJson(jsonDecode(response.body)["posts"]);
  }
}
