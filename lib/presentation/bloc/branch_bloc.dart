import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/domain/models/json/json.dart';
import 'package:treechan/domain/repositories/thread_repository.dart';
import 'package:treechan/exceptions.dart';
import 'package:treechan/presentation/bloc/thread_bloc.dart';
import 'package:treechan/utils/constants/enums.dart';

import '../../domain/models/tab.dart';
import '../../domain/models/tree.dart';
import '../../domain/repositories/branch_repository.dart';
import '../../domain/services/scroll_service.dart';
import '../provider/page_provider.dart';
import 'thread_base.dart';

class BranchBloc extends Bloc<BranchEvent, BranchState> with ThreadBase {
  final ThreadBloc? threadBloc;
  // final BranchTab tab;
  // final PageProvider provider;

  late TreeNode<Post> branch;
  // late ThreadRepository threadRepository;
  BranchRepository branchRepository;

  @override
  List<TreeNode<Post>> get dialogStack =>
      threadBloc == null || threadBloc!.isClosed
          ? _localDialogStack
          : threadBloc!.dialogStack;
  final List<TreeNode<Post>> _localDialogStack = [];

  @override
  Root get threadInfo => threadRepository.threadInfo;

  // final ScrollController scrollController = ScrollController();
  // late final ScrollService scrollService;
  // Key key;
  BranchBloc({
    this.threadBloc,
    required this.branchRepository,
    required ThreadRepository threadRepository,
    required BranchTab tab,
    required PageProvider provider,
    required Key key,
  }) : super(BranchInitialState()) {
    this.threadRepository = threadRepository;
    this.tab = tab;
    this.provider = provider;
    this.key = key;
    scrollController = ScrollController();
    scrollService = ScrollService(
      scrollController,
    );
    on<LoadBranchEvent>(
      (event, emit) async {
        try {
          branch = await branchRepository.getBranch();
          emit(BranchLoadedState(
              branch: branch, threadInfo: threadRepository.threadInfo));
        } on Exception catch (e) {
          emit(BranchErrorState(message: e.toString(), exception: e));
        }
      },
    );
    on<RefreshBranchEvent>(
      (event, emit) async {
        try {
          if (event.source == RefreshSource.branch) {
            if (scrollController.offset != 0) {
              scrollService.saveCurrentScrollInfo();
            }
          }
          await branchRepository.refresh(event.source,
              lastIndex: event.lastIndex);
          add(LoadBranchEvent());
          if (event.source == RefreshSource.branch) {
            if (threadBloc != null && !threadBloc!.isClosed) {
              threadBloc!.add(LoadThreadEvent());
            }

            await Future.delayed(const Duration(milliseconds: 10));

            if (branchRepository.newPostsCount > 0 &&
                scrollController.offset != 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                scrollService.updateScrollPosition();
              });
            }
          }
          if (event.source == RefreshSource.tracker) {
            provider.trackerRepository.updateBranchByTab(
                tab: tab,
                posts: branchRepository.postsCount,
                newPosts: branchRepository.newPostsCount,
                newReplies: branchRepository.newReplies);
          }
        } on ThreadNotFoundException {
          if (event.source != RefreshSource.tracker) {
            provider.showSnackBar('Тред умер');
          }
          provider.trackerRepository.markAsDead(tab);
        } on NoConnectionException {
          // do nothing
        } on Exception catch (e) {
          emit(BranchErrorState(message: "Неизвестная ошибка", exception: e));
        }
      },
    );
  }

  void shrinkBranch(TreeNode<Post> node) async {
    node.parent!.expanded = false;

    /// Prevent scrolling if called from [PostPreviewDialog] or [EndDrawer]
    if (dialogStack.isEmpty) {
      scrollService.scrollToNodeInDirection(node.parent!.getGlobalKey(tab.id),
          direction: AxisDirection.up);
    }
  }

  void shrinkRootBranch(TreeNode<Post> node) {
    final rootNode = Tree.findRootNode(node);
    rootNode.expanded = false;
    final rootPostKey = rootNode.getGlobalKey(tab.id);

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
