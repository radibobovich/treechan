import 'dart:async';

import 'package:treechan/data/thread/thread_loader.dart';
import 'package:treechan/data/thread/thread_refresher.dart';
import 'package:treechan/di/injection.dart';
import 'package:treechan/domain/models/repository_stream.dart';
import 'package:treechan/domain/repositories/manager/repository_manager.dart';
import 'package:treechan/domain/repositories/thread_repository.dart';
import 'package:treechan/utils/constants/dev.dart';
import 'package:treechan/utils/constants/enums.dart';

import '../../../exceptions.dart';
import '../branch_repository.dart';

class BranchRepositoryManager implements RepositoryManager<BranchRepository> {
  static final BranchRepositoryManager _instance =
      BranchRepositoryManager._internal();
  factory BranchRepositoryManager() {
    return _instance;
  }
  BranchRepositoryManager._internal();

  static final List<BranchRepository> _repos = [];

  static late StreamController<RepositoryMessage> _repositoryMessenger;

  void initMessenger(StreamController<RepositoryMessage> repositoryMessenger) {
    BranchRepositoryManager._repositoryMessenger = repositoryMessenger;
  }

  BranchRepository create(ThreadRepository threadRepo, int id) {
    final branchRepo =
        BranchRepository(threadRepository: threadRepo, postId: id);
    _repos.add(branchRepo);
    return branchRepo;
  }

  @override
  BranchRepository add(BranchRepository repo) {
    if (_repos.any((element) =>
        element.boardTag == repo.boardTag &&
        element.postId == repo.postId &&
        element.imageboard == repo.imageboard)) {
      throw DuplicateRepositoryException(tag: repo.boardTag, id: repo.postId);
    }
    _repos.add(repo);
    return repo;
  }

  @override
  BranchRepository? get(Imageboard imageboard, String tag, int id) {
    BranchRepository repo = _repos.firstWhere(
        (element) => element.boardTag == tag && element.postId == id,
        orElse: () {
      return BranchRepository(
          threadRepository: ThreadRepository(
            messenger: _repositoryMessenger,
            imageboard: imageboard,
            boardTag: 'error',
            threadId: 0,
            threadLoader: getIt<IThreadRemoteLoader>(
                param1: imageboard, param2: debugThreadPath),
            threadRefresher: getIt<IThreadRemoteRefresher>(
                param1: imageboard, param2: debugThreadUpdatePaths),
          ),
          postId: 0);
    });
    if (repo.postId == 0) return null;
    return repo;
  }

  @override
  remove(Imageboard imageboard, String tag, int id) {
    _repos.removeWhere((element) =>
        element.boardTag == tag &&
        element.postId == id &&
        element.imageboard == imageboard);
  }
}
