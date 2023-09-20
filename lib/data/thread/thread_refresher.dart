import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:mockito/mockito.dart';
import 'package:treechan/data/thread/response_handler.dart';
import 'package:treechan/di/injection.dart';
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

@Injectable(as: IThreadRefresher, env: [Env.prod])
class ThreadRefresher implements IThreadRefresher {
  ThreadRefresher();
  final IResponseHandler responseHandler = getIt<IResponseHandler>();
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

@Injectable(as: IThreadRefresher, env: [Env.test, Env.dev])
class MockThreadRefresher extends Mock implements IThreadRefresher {
  MockThreadRefresher({@factoryParam required this.assetPaths});
  final List<String> assetPaths;
  int refreshCount = 0;
  @override
  Future<http.Response> _getRefreshResponse(
    String boardTag,
    int threadId,
    int lastPostId,
  ) async {
    String jsonString = await rootBundle.loadString(assetPaths[refreshCount++]);
    http.Response response = http.Response(jsonString, 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }

  @override
  Future<List<Post>> getNewPosts({
    required String boardTag,
    required int threadId,
    required int lastPostId,
  }) async {
    if (refreshCount >= assetPaths.length) {
      debugPrint('No more refreshes left in refresh asset list.');
      return [];
    }
    final http.Response response =
        await _getRefreshResponse(boardTag, threadId, lastPostId);

    debugPrint('Thread $boardTag/$threadId refreshed');
    return postListFromJson(jsonDecode(response.body)["posts"]);
  }
}
