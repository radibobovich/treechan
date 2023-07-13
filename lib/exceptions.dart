class ThreadNotFoundException implements Exception {
  final String message;
  final String tag;
  final int id;

  ThreadNotFoundException(
      {required this.message, required this.tag, required this.id});

  @override
  String toString() {
    return message;
  }
}

class BoardNotFoundException implements Exception {
  final String message;

  BoardNotFoundException({required this.message});

  @override
  String toString() {
    return message;
  }
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
