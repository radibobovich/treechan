import 'dart:io';

import 'package:http/http.dart' as http;

import '../exceptions.dart';
import '../utils/constants/enums.dart';

class BoardFetcher {
  BoardFetcher({required this.boardTag, required this.sortType});

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
