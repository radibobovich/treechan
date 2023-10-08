import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:mockito/mockito.dart';
import 'package:treechan/data/rest/rest_client.dart';
import 'package:treechan/di/injection.dart';
import 'package:treechan/domain/imageboards/imageboard_specific.dart';
import 'package:treechan/domain/models/api/dvach/thread_archive_dvach_api_model.dart';
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
    String? date,
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
    String? date,
  }) async {
    RestClient restClient = getIt<RestClient>(
        instanceName: imageboard.name,
        param1: ImageboardSpecific(imageboard).getDio(boardTag, threadId));

    late final ThreadResponseApiModel apiModel;
    try {
      apiModel = await restClient.loadThread(
          boardTag: boardTag, threadId: threadId, date: date);
    } on ThreadNotFoundException catch (e) {
      debugPrint('ThreadRemoteLoader: 404. Trying to get archive version...');
      try {
        await ImageboardSpecific(imageboard).getDio(boardTag, threadId).get(
            e.requestOptions.baseUrl +
                e.requestOptions.path.replaceFirst('.json', '.html'),
            options: Options(followRedirects: true));
      } on ArchiveRedirectException {
        rethrow;
      } on ThreadNotFoundException {
        rethrow;
      }
    }

    /// TODO: Better create ThreadResponseApiModel.toCoreModel()
    /// so we dont have to check for type here
    if (apiModel is ThreadResponseDvachApiModel) {
      return Thread.fromThreadDvachApi(apiModel).posts;
    } else if (apiModel is ThreadArchiveResponseDvachApiModel) {
      return apiModel.toThreadCoreModel().posts;
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
  Future<List<Post>> getPosts({
    required String boardTag,
    required int threadId,
    String? date,
  }) async {
    final ThreadResponseApiModel apiModel =
        ThreadResponseDvachApiModel.fromJson(
            jsonDecode(await rootBundle.loadString(assetPath)));

    return Thread.fromThreadDvachApi(apiModel as ThreadResponseDvachApiModel)
        .posts;
  }
}

@Deprecated('Use ImageboardSpecific getDio method')
Dio _getDio(String boardTag, int threadId) {
  final Dio dio = Dio();

  dio.interceptors.add(
    InterceptorsWrapper(
      onResponse: (response, handler) {
        if (response.statusCode != null) {
          debugPrint('onResponse: statusCode is ${response.statusCode}');
          switch (response.statusCode) {
            case 200:
              {
                if (response.redirects.isEmpty) break;
                final String origin = response.redirects.first.location.origin;
                final String redirectPath =
                    response.redirects.last.location.path;
                debugPrint('''
ThreadRemoteLoader: got a redirect. Throwing ArchiveRedirectException, redirect
path is ${origin + redirectPath}''');
                throw ArchiveRedirectException(
                  requestOptions: response.requestOptions,
                  baseUrl: origin,
                  redirectPath: redirectPath,
                );
              }
          }
        }
        handler.next(response);
      },
      onError: (e, handler) {
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

          // _onThreadLoadResponseError(response.statusCode!, boardTag, threadId);
        } else {
          handler.next(e);
        }
      },
    ),
  );
  return dio;
}
