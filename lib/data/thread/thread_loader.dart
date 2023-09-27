import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:mockito/mockito.dart';
import 'package:treechan/di/injection.dart';
import 'package:treechan/domain/models/json/json.dart';
import 'package:treechan/exceptions.dart';

import 'response_handler.dart';

abstract class IThreadLoader {
  // ignore: unused_element
  Future<http.Response> _getThreadResponse(String boardTag, int threadId);

  Future<List<Post>> getPosts({
    required String boardTag,
    required int threadId,
  });
}

abstract class IThreadRemoteLoader extends IThreadLoader {}

@Injectable(as: IThreadRemoteLoader, env: [Env.prod])
class ThreadRemoteLoader implements IThreadRemoteLoader {
  ThreadRemoteLoader();

  final IResponseHandler responseHandler = getIt<IResponseHandler>();
  @override
  Future<http.Response> _getThreadResponse(
    String boardTag,
    int threadId,
  ) async {
    final String url =
        "https://2ch.hk/$boardTag/res/${threadId.toString()}.json";

    return await responseHandler.getResponse(
      url: url,
      onResponseError: (int statusCode) =>
          _onThreadLoadResponseError(statusCode, boardTag, threadId),
    );
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

@Injectable(as: IThreadRemoteLoader, env: [Env.test, Env.dev])
class MockThreadRemoteLoader extends Mock implements IThreadRemoteLoader {
  MockThreadRemoteLoader({@factoryParam required this.assetPath});
  final String assetPath;
  @override
  Future<http.Response> _getThreadResponse(
    String boardTag,
    int threadId,
  ) async {
    String jsonString = await rootBundle.loadString(assetPath);
    http.Response response = http.Response(jsonString, 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
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

Never _onThreadLoadResponseError(
    int statusCode, String boardTag, int threadId) {
  if (statusCode == 404) {
    throw ThreadNotFoundException(message: "404", tag: boardTag, id: threadId);
  } else {
    throw Exception(
        "Failed to load thread $boardTag/$threadId. Status code: $statusCode");
  }
}
