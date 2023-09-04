import 'package:treechan/domain/repositories/manager/repository_manager.dart';
import 'package:treechan/domain/repositories/thread_repository.dart';

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

  BranchRepository create(ThreadRepository threadRepo, int id) {
    final branchRepo =
        BranchRepository(threadRepository: threadRepo, postId: id);
    _repos.add(branchRepo);
    return branchRepo;
  }

  @override
  BranchRepository add(BranchRepository repo) {
    if (_repos.any((element) =>
        element.boardTag == repo.boardTag && element.postId == repo.postId)) {
      throw DuplicateRepositoryException(tag: repo.boardTag, id: repo.postId);
    }
    _repos.add(repo);
    return repo;
  }

  @override
  BranchRepository? get(String tag, int id) {
    BranchRepository repo = _repos.firstWhere(
        (element) => element.boardTag == tag && element.postId == id,
        orElse: () {
      return BranchRepository(
          threadRepository: ThreadRepository(boardTag: 'error', threadId: 0),
          postId: 0);
    });
    if (repo.postId == 0) return null;
    return repo;
  }

  @override
  remove(String tag, int id) {
    _repos.removeWhere(
        (element) => element.boardTag == tag && element.postId == id);
  }
}
