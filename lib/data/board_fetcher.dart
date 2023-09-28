import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:treechan/data/rest/rest_client.dart';
import 'package:treechan/di/injection.dart';
import 'package:treechan/domain/models/api/board_api_model.dart';
import 'package:treechan/domain/models/api/dvach/board_dvach_api_model.dart';

import '../domain/models/core/core_models.dart';
import '../exceptions.dart';
import '../utils/constants/enums.dart';

@Deprecated('use interface IBoardFetcher instead')
class BoardFetcherDeprecated {
  BoardFetcherDeprecated({required this.boardTag, required this.sortType});

  final String boardTag;
  final SortBy sortType;
  Future<http.Response> getBoardResponse(int currentPage) async {
    String url = "";
    if (sortType == SortBy.bump) {
      url = "https://2ch.hk/$boardTag/catalog.json";
    } else if (sortType == SortBy.time) {
      url = "https://2ch.hk/$boardTag/catalog_num.json";
    } else if (sortType == SortBy.page) {
      url = "https://2ch.hk/$boardTag/$currentPage.json";
      if (currentPage == 0) {
        url = "https://2ch.hk/$boardTag/index.json";
      }
    }
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 404) {
        throw BoardNotFoundException(
            message: 'Failed to load board $boardTag - board not found.');
      } else if (response.statusCode == 500) {
        throw NoCookieException(
            message:
                'Failed to load board $boardTag - user has to get a cookie before.');
      } else {
        throw FailedResponseException(
            message:
                'Failed to load board $boardTag. Error code: ${response.statusCode}',
            statusCode: response.statusCode);
      }
    } on SocketException {
      throw NoConnectionException('Check your internet connection.');
    }
  }
}

abstract class IBoardFetcher {
  Future<Board> getBoardApiModel(
      int currentPage, String boardTag, SortBy sortType);

  Imageboard get imageboard;
}

@Injectable(as: IBoardFetcher, env: [Environment.prod])
class BoardFetcher implements IBoardFetcher {
  BoardFetcher(
      {@factoryParam required this.imageboard,
      @factoryParam String? assetPath});

  @override
  final Imageboard imageboard;

  @override
  Future<Board> getBoardApiModel(
      int currentPage, String boardTag, SortBy sortType) async {
    // String url = "";
    final RestClient restClient = getIt<RestClient>(
        instanceName: imageboard.name, param1: _getDio(boardTag, currentPage));
    late final BoardResponseApiModel apiModel;
    if (sortType == SortBy.bump) {
      apiModel = await restClient.getBoardCatalog(boardTag: boardTag);
    } else if (sortType == SortBy.time) {
      apiModel = await restClient.getBoardCatalogByTime(boardTag: boardTag);
    } else if (sortType == SortBy.page) {
      if (currentPage == 0) {
        apiModel = await restClient.getBoardIndex(boardTag: boardTag);
      } else {
        apiModel = await restClient.getBoardPage(
            boardTag: boardTag, page: currentPage);
      }
    } else {
      throw Exception("Unknown sort type");
    }

    if (apiModel is BoardResponseDvachApiModel) {
      return Board.fromResponseDvachApi(apiModel);
    } else {
      throw Exception("Unknown board response model");
    }
  }
}

@Injectable(as: IBoardFetcher, env: [Environment.test, Environment.dev])
class MockBoardFetcher implements IBoardFetcher {
  MockBoardFetcher({
    @factoryParam required this.imageboard,
    @factoryParam required this.assetPath,
  });

  @override
  final Imageboard imageboard;
  final String assetPath;

  @override
  Future<Board> getBoardApiModel(
      int currentPage, String boardTag, SortBy sortType) async {
    String jsonString = await rootBundle.loadString(assetPath);

    return Board.fromResponseDvachApi(
        BoardResponseDvachApiModel.fromJson(jsonDecode(jsonString)));
  }
}

Never _onBoardResponseError(int statusCode, String boardTag) {
  if (statusCode == 404) {
    throw BoardNotFoundException(
        message: 'Failed to load board $boardTag - board not found.');
  } else if (statusCode == 500) {
    throw NoCookieException(
        message:
            'Failed to load board $boardTag - user has to get a cookie before.');
  } else {
    throw FailedResponseException(
        message: 'Failed to load board $boardTag. Error code: $statusCode',
        statusCode: statusCode);
  }
}

Dio _getDio(String boardTag, int currentPage) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onResponse: (response, handler) {
        if (response.statusCode != null && response.statusCode != 200) {
          _onBoardResponseError(response.statusCode!, boardTag);
        }

        return handler.next(response);
      },
    ),
  );
  return dio;
}
