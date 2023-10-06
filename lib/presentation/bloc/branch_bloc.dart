import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/domain/models/thread_info.dart';
import 'package:treechan/domain/repositories/thread_repository.dart';
import 'package:treechan/domain/repositories/tracker_repository.dart';
import 'package:treechan/domain/usecases/post_actions.dart';
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

  late TreeNode<Post> branch;
  BranchRepository branchRepository;

  @override
  List<TreeNode<Post>> get dialogStack =>
      threadBloc == null || threadBloc!.isClosed
          ? _localDialogStack
          : threadBloc!.dialogStack;
  final List<TreeNode<Post>> _localDialogStack = [];

  @override
  ThreadInfo get threadInfo => threadRepository.threadInfo;

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
    on<LoadBranchEvent>(_load);

    on<RefreshBranchEvent>(_refresh);
  }
  FutureOr<void> _load(event, emit) async {
    if (isBusy) return;
    isBusy = true;
    try {
      branch = await branchRepository.getBranch();
      emit(BranchLoadedState(
          branch: branch, threadInfo: threadRepository.threadInfo));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        emit(BranchErrorState(
            message: "Проверьте подключение к Интернету.",
            exception: NoConnectionException('')));
      } else {
        emit(BranchErrorState(message: "Неизвестная ошибка Dio", exception: e));
      }
    } on Exception catch (e) {
      emit(BranchErrorState(message: e.toString(), exception: e));
    } finally {
      isBusy = false;
    }
  }

  FutureOr<void> _refresh(event, emit) async {
    if ((tab as BranchTab).imageboard == Imageboard.dvachArchive) return;

    if (isBusy) return;
    isBusy = true;

    /// Trigger appbar refresh indicator
    final currentState = state;
    if (currentState is BranchLoadedState) {
      emit(
        BranchRefreshingState(
          branch: (state as BranchLoadedState).branch,
          threadInfo: (state as BranchLoadedState).threadInfo,
        ),
      );
    }

    try {
      if (event.source == RefreshSource.branch) {
        await _refreshFromBranch(event);
      } else if (event.source == RefreshSource.thread) {
        await _refreshFromThread(event);
      } else if (event.source == RefreshSource.tracker) {
        await _refreshFromTracker(event);
      }
    } on ThreadNotFoundException {
      if (event.source != RefreshSource.tracker) {
        provider.showSnackBar('Тред умер');
      }
      provider.trackerRepository.markAsDead(tab);
    } on DioException catch (e) {
      if (event.source == RefreshSource.branch) {
        if (e.type == DioExceptionType.connectionError) {
          provider.showSnackBar('Проверьте подключение к Интернету.');
        } else {
          provider.showSnackBar('Неизвестная ошибка Dio');
        }
      }
    } on Exception {
      if (event.source == RefreshSource.branch) {
        provider.showSnackBar('Неизвестная ошибка');
      }
    }
  }

  /// Used when user presses refresh button in [BranchScreen]
  Future<void> _refreshFromBranch(event) async {
    if (scrollController.offset != 0) scrollService.saveCurrentScrollInfo();

    TrackerRepository? trackerRepoForThreadRepo = provider.trackerRepository;

    /// Pass trackerRepoForThreadRepo to make related thread repo notify
    /// tracker repo about its new posts
    await branchRepository.refresh(event.source,
        lastIndex: event.lastIndex, trackerRepo: trackerRepoForThreadRepo);

    isBusy = false;
    add(LoadBranchEvent());

    /// Update related thread screen
    if (threadBloc != null && !threadBloc!.isClosed) {
      threadBloc!.add(LoadThreadEvent());
    }

    await Future.delayed(const Duration(milliseconds: 10));

    if (branchRepository.newPostsCount > 0 && scrollController.offset != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollService.updateScrollPosition();
      });
    }

    provider.trackerRepository.updateBranchByTab(
      tab: tab as BranchTab,
      posts: branchRepository.postsCount,
      newPosts: 0,
      forceNewPosts: true,
      newReplies: 0,
      forceNewReplies: true,
    );
    provider.trackerCubit.loadTracker();
    provider.showSnackBar(branchRepository.newPostsCount > 0
        ? 'Новых постов: ${branchRepository.newPostsCount}'
        : 'Нет новых постов');
  }

  /// Called when [ThreadBloc.refresh] calls [refreshRelatedBranches()]
  Future<void> _refreshFromThread(event) async {
    await branchRepository.refresh(event.source,
        lastIndex: event.lastIndex, trackerRepo: null);

    isBusy = false;
    add(LoadBranchEvent());

    await _notifyTracker();

    provider.trackerCubit.loadTracker();
  }

  /// Called when [TrackerCubit] refreshes tracked branch
  Future<void> _refreshFromTracker(event) async {
    TrackerRepository? trackerRepoForThreadRepo = provider.trackerRepository;
    await branchRepository.refresh(event.source,
        lastIndex: event.lastIndex, trackerRepo: trackerRepoForThreadRepo);

    isBusy = false;
    add(LoadBranchEvent());

    await _notifyTracker();
  }

  Future<void> _notifyTracker() async {
    bool shouldNotifyNewPosts = true;
    if (provider.tabManager.currentTab == tab as BranchTab &&
        provider.tabManager.isAppInForeground) {
      shouldNotifyNewPosts = false;
    }
    await provider.trackerRepository.updateBranchByTab(
      tab: tab as BranchTab,
      posts: branchRepository.postsCount,
      newPosts: shouldNotifyNewPosts ? branchRepository.newPostsCount : 0,
      forceNewPosts: shouldNotifyNewPosts ? false : true,
      newReplies: shouldNotifyNewPosts ? branchRepository.newReplies : 0,
      forceNewReplies: shouldNotifyNewPosts ? false : true,
    );
  }

  @override
  void goToPost(TreeNode<Post> node, {required BuildContext? context}) {
    if (context == null) {
      throw Exception('context must be provided for goToPost from branch');
    }
    final goToPostUseCase = GoToPostUseCase();
    goToPostUseCase(
      GoToPostParams(
        threadRepository: threadRepository,
        currentTab: tab,
        animateToBrowserPage: provider.currentPageIndex == 0
            ? () => provider.setCurrentPageIndex(2)
            : null,
        node: node,
        dialogStack: dialogStack,
        popUntil: () =>
            Navigator.of(context).popUntil(ModalRoute.withName('/')),
        addTab: (tab) => provider.addTab(tab),
        scrollService: scrollService,
        threadScrollService: threadBloc != null && !threadBloc!.isClosed
            ? threadBloc!.scrollService
            : null,
        getThreadScrollService: () async {
          final scrollService = provider.tabManager.getThreadScrollService(
              imageboard: (tab as BranchTab).imageboard,
              boardTag: (tab as BranchTab).tag,
              threadId: (tab as BranchTab).threadId);
          await Future.delayed(const Duration(seconds: 1));
          return scrollService;
        },
      ),
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

  void resetNewPostsCount() {
    provider.trackerRepository.updateBranchByTab(
        tab: tab as BranchTab,
        posts: null,
        newPosts: 0,
        newReplies: 0,
        forceNewPosts: true,
        forceNewReplies: true);
    provider.trackerCubit.loadTracker();
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
  ThreadInfo threadInfo;
  BranchLoadedState({required this.branch, required this.threadInfo});
}

class BranchRefreshingState extends BranchLoadedState {
  BranchRefreshingState({required super.branch, required super.threadInfo});
}

class BranchErrorState extends BranchState {
  final String message;
  final Exception? exception;
  BranchErrorState({required this.message, this.exception});
}
