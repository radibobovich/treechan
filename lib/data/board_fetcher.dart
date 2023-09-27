import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:treechan/data/thread/response_handler.dart';
import 'package:treechan/di/injection.dart';

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
  Future<http.Response> getBoardResponse(
      int currentPage, String boardTag, SortBy sortType);
}

@Injectable(as: IBoardFetcher, env: [Environment.prod])
class BoardFetcher implements IBoardFetcher {
  @override
  Future<http.Response> getBoardResponse(
      int currentPage, String boardTag, SortBy sortType) async {
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
    final IResponseHandler responseHandler = getIt<IResponseHandler>();
    return await responseHandler.getResponse(
        url: url,
        onResponseError: (statusCode) =>
            _onBoardResponseError(statusCode, boardTag));
  }
}

@Injectable(as: IBoardFetcher, env: [Environment.test, Environment.dev])
class MockBoardFetcher implements IBoardFetcher {
  MockBoardFetcher({@factoryParam required this.assetPath});
  final String assetPath;
  @override
  Future<http.Response> getBoardResponse(
      int currentPage, String boardTag, SortBy sortType) async {
    String jsonString = await rootBundle.loadString(assetPath);
    http.Response response = http.Response(jsonString, 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
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
