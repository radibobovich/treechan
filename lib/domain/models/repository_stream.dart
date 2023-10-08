import 'package:treechan/domain/repositories/repository.dart';

abstract class RepositoryMessage {}

class RepositoryRedirectRequest implements RepositoryMessage {
  RepositoryRedirectRequest({
    required this.repository,
    required this.baseUrl,
    required this.redirectPath,
  });
  final Repository repository;
  final String baseUrl;
  final String redirectPath;
}

// class RepositoryRedirectResponse implements RepositoryMessage {
//   RepositoryRedirectResponse({required this.date});
//   final String? date;
// }
