import 'package:dio/dio.dart';

class ThreadNotFoundException extends DioException {
  // final String message;
  final String tag;
  final int id;

  ThreadNotFoundException(
      {required super.message,
      required this.tag,
      required this.id,
      required super.requestOptions});

  @override
  String toString() {
    return message ?? '';
  }
}

class ArchiveRedirectException extends DioException {
  ArchiveRedirectException(
      {required super.requestOptions,
      required this.baseUrl,
      required this.redirectPath});
  final String baseUrl;
  final String redirectPath;
  String get url => baseUrl + redirectPath;
}

class BoardNotFoundException implements Exception {
  final String message;

  BoardNotFoundException({required this.message});

  @override
  String toString() {
    return message;
  }
}

class NoCookieException implements Exception {
  final String message;
  NoCookieException({required this.message});
}

class FailedResponseException implements Exception {
  final String message;
  final int statusCode;
  FailedResponseException({required this.message, required this.statusCode});

  @override
  String toString() {
    return message;
  }
}

class NoConnectionException implements Exception {
  final String message;
  NoConnectionException(this.message);

  @override
  String toString() {
    return message;
  }
}

class TreeBuilderTimeoutException implements Exception {
  final String message;
  TreeBuilderTimeoutException(this.message);

  @override
  String toString() {
    return message;
  }
}

class DuplicateRepositoryException implements Exception {
  final String tag;
  final int id;
  DuplicateRepositoryException({required this.tag, required this.id});

  @override
  String toString() {
    return "Attempt to add duplicate repository with tag $tag and id $id.";
  }
}
