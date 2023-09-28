import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:mockito/mockito.dart';
import 'package:treechan/data/rest/rest_client.dart';
import 'package:treechan/di/injection.dart';
import 'package:treechan/domain/models/api/dvach/thread_dvach_api_model.dart';
import 'package:treechan/domain/models/api/thread_api_model.dart';
import 'package:treechan/exceptions.dart';
import 'package:treechan/utils/constants/enums.dart';

import '../../domain/models/core/post.dart';
import '../../domain/models/core/thread.dart';

abstract class IThreadLoader {
  Future<List<Post>> getPosts({
    required String boardTag,
    required int threadId,
  });
}

abstract class IThreadRemoteLoader extends IThreadLoader {}

@Injectable(as: IThreadRemoteLoader, env: [Env.prod])
class ThreadRemoteLoader implements IThreadRemoteLoader {
  ThreadRemoteLoader({
    @factoryParam required this.imageboard,
    @factoryParam required String assetPath,
  });
  final Imageboard imageboard;

  @override
  Future<List<Post>> getPosts({
    required String boardTag,
    required int threadId,
  }) async {
    final RestClient restClient = getIt<RestClient>(
        instanceName: imageboard.name, param1: _getDio(boardTag, threadId));
    final ThreadResponseApiModel apiModel =
        await restClient.loadThread(boardTag: boardTag, threadId: threadId);

    /// TODO: Better create ThreadResponseApiModel.toCoreModel()
    /// so we dont have to check for type here
    if (apiModel is ThreadResponseDvachApiModel) {
      return Thread.fromThreadDvachApi(apiModel).posts;
    } else {
      throw Exception("Unknown thread response model");
    }
  }
}

/// Mock for 2ch.hk
@Injectable(as: IThreadRemoteLoader, env: [Env.test, Env.dev])
class MockThreadRemoteLoader extends Mock implements IThreadRemoteLoader {
  MockThreadRemoteLoader(
      {@factoryParam required this.imageboard,
      @factoryParam required this.assetPath});
  final Imageboard imageboard;

  final String assetPath;

  @override
  Future<List<Post>> getPosts(
      {required String boardTag, required int threadId}) async {
    final ThreadResponseApiModel apiModel =
        ThreadResponseDvachApiModel.fromJson(
            jsonDecode(await rootBundle.loadString(assetPath)));

    return Thread.fromThreadDvachApi(apiModel as ThreadResponseDvachApiModel)
        .posts;
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

Dio _getDio(String boardTag, int threadId) {
  final Dio dio = Dio();

  dio.interceptors.add(
    InterceptorsWrapper(onResponse: (Response response, handler) {
      if (response.statusCode != null && response.statusCode != 200) {
        _onThreadLoadResponseError(response.statusCode!, boardTag, threadId);
      }
      return handler.next(response);
    }),
  );
  return dio;
}
