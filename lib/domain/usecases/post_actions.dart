import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/domain/models/tab.dart';
import 'package:treechan/domain/models/tree.dart';
import 'package:treechan/domain/repositories/thread_repository.dart';
import 'package:treechan/domain/services/scroll_service.dart';

abstract class BaseUseCaseWithParams<Params, Result> {
  Future<Result> call(Params params);
}

class GoToPostUseCase implements BaseUseCaseWithParams<GoToPostParams, void> {
  GoToPostUseCase();
  @override
  Future<void> call(GoToPostParams params) async {
    final ThreadRepository threadRepository = params.threadRepository;
    final tab = params.currentTab;
    final node = params.node;
    final dialogStack = params.dialogStack;
    final popUntil = params.popUntil;
    final addTab = params.addTab;
    ScrollService? scrollService = params.scrollService;
    final ScrollService? threadScrollService = params.threadScrollService;
    final Function? getThreadScrollService = params.getThreadScrollService;

    int tabId = tab.id;

    if (params.animateToBrowserPage != null) {
      params.animateToBrowserPage!();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    /// Check if this action was called in post preview dialog
    if (dialogStack.isNotEmpty) {
      final TreeNode<Post> visibleNode = dialogStack.first;
      popUntil();

      /// Find current root tree visible post belongs to.
      final TreeNode<Post> currentRoot = Tree.findRootNode(visibleNode);

      /// Check if desirable post is in the same tree as visible post.
      if (params.animateToBrowserPage != null &&
          node == Tree.findNode([currentRoot], node.data.id)) {
        scrollService.scrollToParent(node, tab.id);
      } else {
        if (tab is BranchTab) {
          final record = await _handleScrollFromBranchTab(
            threadScrollService,
            tab,
            getThreadScrollService,
            addTab,
          );

          tabId = record.$1;
          scrollService = record.$2;
        }

        scrollService.scrollToNodeByPost(
          node.data,
          tabId,
          roots: await threadRepository.getRoots(),
        );
      }
    } else {
      popUntil();
      if (tab is BranchTab) {
        final record = await _handleScrollFromBranchTab(
          threadScrollService,
          tab,
          getThreadScrollService,
          addTab,
        );

        tabId = record.$1;
        scrollService = record.$2;
      }
      if (node.parent == null) {
        scrollService.scrollToNodeByPost(
          node.data,
          tab.id,
          roots: await threadRepository.getRoots(),
        );
        return;
      } else {
        scrollService.scrollToNode(
          node,
          tab.id,
        );
      }
    }
  }

  Future<(int, ScrollService)> _handleScrollFromBranchTab(
    ScrollService? threadScrollService,
    BranchTab tab,
    Function? getThreadScrollService,
    Function addTab,
  ) async {
    assert(threadScrollService != null || getThreadScrollService != null,
        'No way to get threadScrollService.');
    ThreadTab? threadTab = tab.getParentThreadTab();
    threadTab ??= ThreadTab(
        imageboard: tab.imageboard,
        id: tab.threadId,
        tag: tab.tag,
        prevTab: boardListTab,
        name: null);

    /// Adds tab if [ThreadTab] was closed or animates to it if not
    addTab(threadTab);

    final tabId = threadTab.id;

    ScrollService? scrollService =
        threadScrollService ?? await getThreadScrollService!();

    if (scrollService == null) {
      throw Exception('Failed to get threadScrollService.');
    }

    /// wait for tab change
    await Future.delayed(const Duration(milliseconds: 300));
    return (tabId, scrollService);
  }
}

class GoToPostParams {
  GoToPostParams({
    required this.threadRepository,
    required this.currentTab,
    required this.node,
    required this.dialogStack,
    required this.popUntil,
    required this.animateToBrowserPage,
    required this.addTab,
    required this.scrollService,
    required this.threadScrollService,
    required this.getThreadScrollService,
  });
  final ThreadRepository threadRepository;
  final IdMixin currentTab;
  final TreeNode<Post> node;
  final List<TreeNode<Post>> dialogStack;
  final Function popUntil;
  final Function? animateToBrowserPage;
  final Function addTab;
  final ScrollService scrollService;
  final ScrollService? threadScrollService;
  final Function? getThreadScrollService;
}
