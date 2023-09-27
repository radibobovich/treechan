import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:treechan/di/injection.dart';
import 'package:treechan/exceptions.dart';

import 'package:injectable/injectable.dart';

abstract class IResponseHandler {
  Future<http.Response> getResponse({
    required String url,
    required Never Function(int) onResponseError,
    // required String boardTag,
    // required int threadId,
  });
}

@LazySingleton(as: IResponseHandler, env: [Env.test, Env.dev, Env.prod])
class ResponseHandler implements IResponseHandler {
  @override
  Future<http.Response> getResponse({
    required String url,
    required Never Function(int) onResponseError,
    // required String boardTag,
    // required int threadId,
  }) async {
    http.Response response;
    try {
      response = await http.get(Uri.parse(url));
    } on SocketException {
      throw NoConnectionException('Check your internet connection.');
    }

    if (response.statusCode == 200) {
      return response;
    } else {
      onResponseError(response.statusCode);
    }
  }
}
