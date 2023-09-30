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
  ThreadInfo get threadInfo => threadRepository.threadInfo;

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
        } on DioException catch (e) {
          if (e.type == DioExceptionType.connectionError) {
            emit(BranchErrorState(
                message: "Проверьте подключение к Интернету.", exception: e));
          } else {
            emit(BranchErrorState(
                message: "Неизвестная ошибка Dio", exception: e));
          }
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
          TrackerRepository? trackerRepoForThreadRepo =
              event.source == RefreshSource.thread
                  ? null
                  : provider.trackerRepository;
          await branchRepository.refresh(event.source,
              lastIndex: event.lastIndex,
              trackerRepo: trackerRepoForThreadRepo);
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
          if (event.source == RefreshSource.tracker ||
              event.source == RefreshSource.thread) {
            bool shouldNotifyNewPosts = true;
            if (provider.tabManager.currentTab == tab &&
                provider.tabManager.isAppInForeground) {
              shouldNotifyNewPosts = false;
            }
            await provider.trackerRepository.updateBranchByTab(
              tab: tab,
              posts: branchRepository.postsCount,
              newPosts:
                  shouldNotifyNewPosts ? branchRepository.newPostsCount : 0,
              forceNewPosts: shouldNotifyNewPosts ? false : true,
              newReplies:
                  shouldNotifyNewPosts ? branchRepository.newReplies : 0,
              forceNewReplies: shouldNotifyNewPosts ? false : true,
            );
            if (event.source == RefreshSource.thread) {
              provider.trackerCubit.loadTracker();
            }
          } else if (event.source == RefreshSource.branch) {
            provider.trackerRepository.updateBranchByTab(
              tab: tab,
              posts: branchRepository.postsCount,
              newPosts: 0,
              forceNewPosts: true,
              newReplies: 0,
              forceNewReplies: true,
            );
            provider.trackerCubit.loadTracker();
          }
        } on ThreadNotFoundException {
          if (event.source != RefreshSource.tracker) {
            provider.showSnackBar('Тред умер');
          }
          provider.trackerRepository.markAsDead(tab);
        } on DioException catch (e) {
          if (e.type == DioExceptionType.connectionError) {
            provider.showSnackBar('Проверьте подключение к Интернету.');
          } else {
            provider.showSnackBar('Неизвестная ошибка Dio');
          }
        } on Exception {
          provider.showSnackBar('Неизвестная ошибка');
        }
      },
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
              boardTag: (tab as TagMixin).tag,
              threadId: (tab as BranchTab).threadId);
          await Future.delayed(const Duration(seconds: 2));
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

class BranchErrorState extends BranchState {
  final String message;
  final Exception? exception;
  BranchErrorState({required this.message, this.exception});
}
