import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:mockito/mockito.dart';
import 'package:treechan/data/rest/rest_client.dart';
import 'package:treechan/di/injection.dart';
import 'package:treechan/domain/imageboards/imageboard_specific.dart';
import 'package:treechan/domain/models/api/dvach/posts_after_dvach_api_model.dart';
import 'package:treechan/domain/models/api/posts_after_api_model.dart';
import 'package:treechan/exceptions.dart';
import 'package:treechan/utils/constants/enums.dart';

import '../../domain/models/core/post.dart';

abstract class IThreadRefresher {
  Future<List<Post>> getNewPosts(
      {required String boardTag,
      required int threadId,
      required int lastPostId});
}

abstract class IThreadRemoteRefresher extends IThreadRefresher {}

@Injectable(as: IThreadRemoteRefresher, env: [Env.prod])
class ThreadRemoteRefresher implements IThreadRemoteRefresher {
  ThreadRemoteRefresher(
      {@factoryParam required this.imageboard,
      @factoryParam required assetPaths});
  final Imageboard imageboard;

  @override
  Future<List<Post>> getNewPosts({
    required String boardTag,
    required int threadId,
    required int lastPostId,
  }) async {
    final RestClient restClient = getIt<RestClient>(
        instanceName: imageboard.name,
        param1: ImageboardSpecific(imageboard).getDio(boardTag, threadId));

    final PostsAfterApiModel apiModel = await restClient.getPostsAfter(
        boardTag: boardTag, threadId: threadId, id: lastPostId + 1);

    debugPrint('Thread $boardTag/$threadId refreshed');

    if (apiModel is PostsAfterDvachApiModel) {
      return apiModel.posts.map((post) => Post.fromDvachApi(post)).toList();
    } else {
      throw Exception('Unknown api model type');
    }
  }
}

@Injectable(as: IThreadRemoteRefresher, env: [Env.test, Env.dev])
class MockThreadRemoteRefresher extends Mock implements IThreadRemoteRefresher {
  MockThreadRemoteRefresher(
      {@factoryParam required this.imageboard,
      @factoryParam required this.assetPaths});
  final Imageboard imageboard;
  final List<String> assetPaths;
  int refreshCount = 0;
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

    final PostsAfterApiModel apiModel = PostsAfterDvachApiModel.fromJson(
      jsonDecode(await rootBundle.loadString(assetPaths[refreshCount++])),
    );

    debugPrint('Thread $boardTag/$threadId refreshed');

    return (apiModel as PostsAfterDvachApiModel)
        .posts
        .map((post) => Post.fromDvachApi(post))
        .toList();
  }
}

@Deprecated('Use ImageboardSpecific instead')
Dio _getDio(String boardTag, int threadId) {
  final Dio dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(onError: (e, handler) {
      if (e.response?.statusCode != null) {
        switch (e.response!.statusCode) {
          case 404:
            throw ThreadNotFoundException(
              message: "404",
              tag: boardTag,
              id: threadId,
              requestOptions: e.requestOptions,
            );
        }
      } else {
        handler.next(e);
      }
    }),
  );
  return dio;
}
