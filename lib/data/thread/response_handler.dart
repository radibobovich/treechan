import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:treechan/exceptions.dart';

abstract class IResponseHandler {
  Future<http.Response> getResponse({
    required String url,
    required String boardTag,
    required int threadId,
  });
}

class ResponseHandler implements IResponseHandler {
  @override
  Future<http.Response> getResponse({
    required String url,
    required String boardTag,
    required int threadId,
  }) async {
    http.Response response;
    try {
      response = await http.get(Uri.parse(url));
    } on SocketException {
      throw NoConnectionException('Check your internet connection.');
    }

    if (response.statusCode == 200) {
      return response;
    } else if (response.statusCode == 404) {
      throw ThreadNotFoundException(
          message: "404", tag: boardTag, id: threadId);
    } else {
      throw Exception(
          "Failed to fetch thread $boardTag/$threadId. Status code: ${response.statusCode}");
    }
  }
}

class MockLoadResponseHandler extends Mock implements IResponseHandler {
  MockLoadResponseHandler({required this.assetPath});
  final String assetPath;
  @override
  Future<http.Response> getResponse({
    required String url,
    required String boardTag,
    required int threadId,
  }) async {
    String jsonString = await rootBundle.loadString(assetPath);
    http.Response response = http.Response(jsonString, 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }
}

class MockRefreshResponseHandler extends Mock implements IResponseHandler {
  MockRefreshResponseHandler({required this.assetPaths});

  final List<String> assetPaths;
  int refreshCount = 0;

  @override
  Future<http.Response> getResponse({
    required String url,
    required String boardTag,
    required int threadId,
  }) async {
    String jsonString = await rootBundle.loadString(assetPaths[refreshCount++]);
    http.Response response = http.Response(jsonString, 200, headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
    });

    return response;
  }
}
