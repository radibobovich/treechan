import 'dart:async';

import 'package:treechan/data/thread/thread_loader.dart';
import 'package:treechan/data/thread/thread_refresher.dart';
import 'package:treechan/di/injection.dart';
import 'package:treechan/domain/models/repository_stream.dart';
import 'package:treechan/domain/repositories/manager/repository_manager.dart';
import 'package:treechan/utils/constants/dev.dart';
import 'package:treechan/utils/constants/enums.dart';

import '../../../exceptions.dart';
import '../thread_repository.dart';

class ThreadRepositoryManager implements RepositoryManager<ThreadRepository> {
  static final ThreadRepositoryManager _instance =
      ThreadRepositoryManager._internal();
  factory ThreadRepositoryManager() => _instance;
  ThreadRepositoryManager._internal();

  static final List<ThreadRepository> _repos = [];

  static late StreamController<RepositoryMessage> _repositoryMessenger;

  void initMessenger(StreamController<RepositoryMessage> repositoryMessenger) {
    ThreadRepositoryManager._repositoryMessenger = repositoryMessenger;
  }

  /// Creates new repository with [tag] and [id].
  ThreadRepository create(Imageboard imageboard, String tag, int id,
      {String? archiveDate}) {
    final threadRepo = ThreadRepository(
        messenger: _repositoryMessenger,
        imageboard: imageboard,
        boardTag: env == Env.prod ? tag : debugBoardTag,
        threadId: env == Env.prod ? id : debugThreadId,
        archiveDate: archiveDate,
        // param1 only used in test and dev environments
        threadLoader: getIt<IThreadRemoteLoader>(
            param1: imageboard, param2: debugThreadPath),
        threadRefresher: getIt<IThreadRemoteRefresher>(
            param1: imageboard, param2: debugThreadUpdatePaths));
    _repos.add(threadRepo);
    return threadRepo;
  }

  /// Adds [repo] to the list of repositories. Returns added repository.
  @override
  ThreadRepository add(ThreadRepository repo) {
    // check if repo already exists
    if (_repos.any((element) =>
        element.boardTag == repo.boardTag &&
        element.threadId == repo.threadId &&
        element.imageboard == repo.imageboard)) {
      throw DuplicateRepositoryException(tag: repo.boardTag, id: repo.threadId);
    }
    _repos.add(repo);
    return repo;
  }

  @override
  remove(Imageboard imageboard, String tag, int id) {
    _repos.removeWhere((element) =>
        element.boardTag == tag &&
        element.threadId == id &&
        element.imageboard == imageboard);
  }

  /// Returns repository from the list of repositories if it exists.
  /// Otherwise creates new repository, adds it to the list and returns it.
  @override
  ThreadRepository get(Imageboard imageboard, String tag, int id,
      {String? date}) {
    return _repos.firstWhere(
        (element) =>
            element.boardTag == tag &&
            element.threadId == id &&
            element.imageboard == imageboard, orElse: () {
      return create(imageboard, tag, id, archiveDate: date);
    });
  }
}
