import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:mockito/mockito.dart';
import 'package:treechan/di/injection.dart';
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

@Injectable(as: IThreadLoader, env: [Env.prod])
class ThreadLoader implements IThreadLoader {
  ThreadLoader();

  final IResponseHandler responseHandler = getIt<IResponseHandler>();
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

@Injectable(as: IThreadLoader, env: [Env.test, Env.dev])
class MockThreadLoader extends Mock implements IThreadLoader {
  MockThreadLoader({@factoryParam required this.assetPath});
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
