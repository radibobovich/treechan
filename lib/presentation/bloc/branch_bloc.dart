import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/domain/models/json/json.dart';
import 'package:treechan/presentation/bloc/thread_bloc.dart';
import 'package:treechan/utils/constants/enums.dart';

import '../../domain/models/tab.dart';
import '../../domain/models/tree.dart';
import '../../domain/repositories/branch_repository.dart';
import '../../domain/services/scroll_service.dart';
import '../../domain/repositories/thread_repository.dart';

class BranchBloc extends Bloc<BranchEvent, BranchState> {
  final ThreadBloc threadBloc;
  final int postId;
  final BranchTab currentTab;
  final IdMixin prevTab;

  late TreeNode<Post> branch;
  late ThreadRepository threadRepository;
  late BranchRepository branchRepository;

  /// Every time new post preview dialog opens the node from which it
  /// has been opened adds here.
  /// Used to check if some post is actually in current visible tree.
  List<TreeNode<Post>> get dialogStack =>
      threadBloc.isClosed ? _localDialogStack : threadBloc.dialogStack;
  final List<TreeNode<Post>> _localDialogStack = [];

  Root get threadInfo => threadRepository.threadInfo;
  final ScrollController scrollController = ScrollController();
  late final ScrollService scrollService;
  Key key;
  BranchBloc(
      {required this.threadBloc,
      required this.postId,
      required this.currentTab,
      required this.prevTab,
      required this.key})
      : super(BranchInitialState()) {
    threadRepository = threadBloc.threadRepository;
    branchRepository =
        BranchRepository(threadRepository: threadRepository, postId: postId);
    scrollService = ScrollService(
      scrollController,
    );
    on<LoadBranchEvent>(
      (event, emit) async {
        try {
          branch = await branchRepository.getBranch();
          emit(BranchLoadedState(
              branch: branch,
              threadInfo: threadBloc.threadRepository.threadInfo));
        } on Exception catch (e) {
          emit(BranchErrorState(message: e.toString(), exception: e));
        }
      },
    );
    on<RefreshBranchEvent>(
      (event, emit) async {
        int oldPostCount = 0;
        if (event.source == RefreshSource.branch) {
          oldPostCount = Tree.countNodes(branch);

          if (oldPostCount > 0 && scrollController.offset != 0) {
            scrollService.saveCurrentScrollInfo();
          }
        }
        await branchRepository.refresh(event.source,
            lastIndex: event.lastIndex);
        add(LoadBranchEvent());
        if (event.source == RefreshSource.branch) {
          if (!threadBloc.isClosed) threadBloc.add(LoadThreadEvent());

          int newPostCount = Tree.countNodes(branch);

          await Future.delayed(const Duration(milliseconds: 10));

          if (oldPostCount > 0 &&
              newPostCount > oldPostCount &&
              scrollController.offset != 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              scrollService.updateScrollPosition();
            });
          }
        }
      },
    );
  }

  void shrinkBranch(TreeNode<Post> node) async {
    node.parent!.expanded = false;

    /// Prevent scrolling if called from [PostPreviewDialog] or [EndDrawer]
    if (dialogStack.isEmpty) {
      scrollService.scrollToNodeInDirection(
          node.parent!.getGlobalKey(currentTab.id),
          direction: AxisDirection.up);
    }
  }

  void shrinkRootBranch(TreeNode<Post> node) {
    final rootNode = Tree.findRootNode(node);
    rootNode.expanded = false;
    final rootPostKey = rootNode.getGlobalKey(currentTab.id);

    /// Prevent scrolling if called from [PostPreviewDialog] or [EndDrawer]
    if (dialogStack.isEmpty) {
      scrollService.scrollToNodeInDirection(rootPostKey,
          direction: AxisDirection.up);
    }
  }
}

abstract class BranchEvent {}

class LoadBranchEvent extends BranchEvent {}

class RefreshBranchEvent extends BranchEvent {
  RefreshSource source;
  int? lastIndex;
  RefreshBranchEvent(this.source, {this.lastIndex}) {
    if (source == RefreshSource.thread) {
      assert(lastIndex != null,
          'lastIndex must be provided for RefreshSource.thread');
    }
  }
}

abstract class BranchState {}

class BranchInitialState extends BranchState {}

class BranchLoadedState extends BranchState {
  TreeNode<Post> branch;
  Root threadInfo;
  BranchLoadedState({required this.branch, required this.threadInfo});
}

class BranchErrorState extends BranchState {
  final String message;
  final Exception? exception;
  BranchErrorState({required this.message, this.exception});
}
