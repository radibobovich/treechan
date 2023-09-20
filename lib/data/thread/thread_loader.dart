import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:treechan/domain/models/json/json.dart';

import 'response_handler.dart';

abstract class IThreadLoader {
  // ignore: unused_element
  Future<http.Response> _getThreadResponse(String boardTag, int threadId);

  Future<List<Post>> getPosts({
    required String boardTag,
    required int threadId,
  });
}

class ThreadLoader implements IThreadLoader {
  const ThreadLoader(this.responseHandler);
  final IResponseHandler responseHandler;
  @override
  Future<http.Response> _getThreadResponse(
    String boardTag,
    int threadId,
  ) async {
    final String url =
        "https://2ch.hk/$boardTag/res/${threadId.toString()}.json";

    return await responseHandler.getResponse(
        url: url, boardTag: boardTag, threadId: threadId);
  }

  @override
  Future<List<Post>> getPosts(
      {required String boardTag, required int threadId}) async {
    final http.Response response = await _getThreadResponse(boardTag, threadId);

    Root decodedResponse = Root.fromJson(jsonDecode(response.body));
    // threadInfo = decodedResponse;
    return decodedResponse.threads!.first.posts;
  }
}
