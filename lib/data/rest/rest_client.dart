import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:treechan/di/injection.dart';
import 'package:treechan/domain/models/api/board_api_model.dart';
import 'package:treechan/domain/models/api/dvach/board_dvach_api_model.dart';
import 'package:retrofit/retrofit.dart';
import 'package:treechan/domain/models/api/dvach/posts_after_dvach_api_model.dart';
import 'package:treechan/domain/models/api/dvach/thread_dvach_api_model.dart';
import 'package:treechan/domain/models/api/posts_after_api_model.dart';
import 'package:treechan/domain/models/api/thread_api_model.dart';

part '../../generated/data/rest/rest_client.g.dart';

abstract class RestClient {
  Future<List<BoardApiModel>> getBoards();

  Future<BoardResponseApiModel> getBoardIndex({required String boardTag});

  Future<BoardResponseApiModel> getBoardCatalog({required String boardTag});

  Future<BoardResponseApiModel> getBoardCatalogByTime(
      {required String boardTag});

  Future<BoardResponseApiModel> getBoardPage({
    required String boardTag,
    required int page,
  });

  Future<ThreadResponseApiModel> loadThread({
    required String boardTag,
    required int threadId,
  });

  Future<PostsAfterApiModel> getPostsAfter({
    required String boardTag,
    required int threadId,
    required int id,
  });
}

@Named('dvach')
@Injectable(as: RestClient, env: [Env.test, Env.dev, Env.prod])
@RestApi(baseUrl: 'https://2ch.hk/', parser: Parser.JsonSerializable)
abstract class DvachRestClient implements RestClient {
  @factoryMethod
  factory DvachRestClient(@factoryParam Dio dio) = _DvachRestClient;

  @override
  @GET("/api/mobile/v2/boards")
  Future<List<BoardDvachApiModel>> getBoards();

  @override
  @GET("/{board}/index.json")
  Future<BoardResponseDvachApiModel> getBoardIndex(
      {@Path("board") required String boardTag});

  @override
  @GET("/{board}/catalog.json")
  Future<BoardResponseDvachApiModel> getBoardCatalog(
      {@Path("board") required String boardTag});

  @override
  @GET("/{board}/catalog_num.json")
  Future<BoardResponseDvachApiModel> getBoardCatalogByTime(
      {@Path("board") required String boardTag});

  @override
  @GET("/{board}/{page}.json")
  Future<BoardResponseDvachApiModel> getBoardPage({
    @Path("board") required String boardTag,
    @Path("page") required int page,
  });

  @override
  @GET('/{board}/res/{thread}.json')
  Future<ThreadResponseDvachApiModel> loadThread({
    @Path("board") required String boardTag,
    @Path("thread") required int threadId,
  });

  @override
  @GET("/api/mobile/v2/after/{board}/{thread}/{id}")
  Future<PostsAfterDvachApiModel> getPostsAfter({
    @Path("board") required String boardTag,
    @Path("thread") required int threadId,
    @Path("id") required int id,
  });
}
