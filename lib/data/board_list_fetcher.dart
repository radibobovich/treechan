import 'dart:io';

import 'package:http/http.dart' as http;

import '../exceptions.dart';

class BoardListFetcher {
  static Future<String?> getBoardListResponse() async {
    String url = "https://2ch.hk/api/mobile/v2/boards";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw FailedResponseException(
            message:
                'Failed to load board list. Error code: ${response.statusCode}',
            statusCode: response.statusCode);
      }
    } on SocketException {
      throw NoConnectionException('Check your internet connection.');
    }
  }
}
