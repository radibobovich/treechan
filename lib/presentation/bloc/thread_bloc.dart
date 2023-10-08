import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/domain/models/thread_info.dart';
import 'package:treechan/domain/services/scroll_service.dart';
import 'package:treechan/domain/usecases/post_actions.dart';
import 'package:treechan/exceptions.dart';
import 'package:treechan/presentation/bloc/thread_base.dart';
import 'package:treechan/presentation/provider/page_provider.dart';
import 'package:treechan/utils/constants/enums.dart';

import '../../domain/models/core/core_models.dart';
import '../../domain/models/tab.dart';
import '../../domain/models/tree.dart';
import '../../domain/repositories/thread_repository.dart';

class ThreadBloc extends Bloc<ThreadEvent, ThreadState> with ThreadBase {
  final ScrollController endDrawerScrollController = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  double? endDrawerScrollPosition;

  @override
  late ThreadInfo threadInfo;
  ThreadBloc({
    required ThreadRepository threadRepository,
    required ThreadTab tab,
    required PageProvider provider,
    required Key key,
  }) : super(ThreadInitialState()) {
    this.threadRepository = threadRepository;
    this.tab = tab;
    this.provider = provider;
    this.key = key;
    scrollController = ScrollController();
    scrollService = ScrollService(scrollController);

    on<LoadThreadEvent>(_load);
    on<RefreshThreadEvent>(_refresh);
  }
  FutureOr<void> _load(event, emit) async {
    if (isBusy) return;
    isBusy = true;
    try {
      final roots = await threadRepository.getRoots();
      threadInfo = threadRepository.threadInfo;
      emit(ThreadLoadedState(
        roots: roots,
        threadInfo: threadInfo,
      ));
    } on ThreadNotFoundException catch (e) {
      emit(ThreadErrorState(message: "404 - Тред не найден", exception: e));
    } on ArchiveRedirectException catch (e) {
      emit(ThreadErrorState(
          message: 'Перенаправление на архивный тред...', exception: e));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        emit(ThreadErrorState(
            message: "Проверьте подключение к Интернету.",
            exception: NoConnectionException('')));
      } else {
        emit(ThreadErrorState(message: "Неизвестная ошибка Dio", exception: e));
      }
    } on TreeBuilderTimeoutException catch (e) {
      emit(ThreadErrorState(
          message: "Построение дерева заняло слишком много времени."
              "Попробуйте открыть тред в классическом режиме.",
          exception: e));
    } on Exception catch (e) {
      emit(ThreadErrorState(message: "Неизвестная ошибка", exception: e));
    } finally {
      isBusy = false;
    }
  }

  FutureOr<void> _refresh(event, emit) async {
    if ((tab as ThreadTab).imageboard == Imageboard.dvachArchive) return;
    if (isBusy) return;
    isBusy = true;

    /// Trigger appbar refresh indicator
    final currentState = state;
    if (currentState is ThreadLoadedState) {
      emit(
        ThreadRefreshingState(
            roots: (state as ThreadLoadedState).roots,
            threadInfo: (state as ThreadLoadedState).threadInfo),
      );
    }

    try {
      if (event.source == RefreshSource.thread) {
        await _refreshFromThread();
      } else if (event.source == RefreshSource.tracker) {
        await _refreshFromTracker();
      } else if (event.source == RefreshSource.branch) {
        throw Exception('You should use ThreadRepository.refresh() method while'
            ' refreshing from branch');
      }
    } on ThreadNotFoundException {
      if (event.source == RefreshSource.thread) {
        provider.showSnackBar('Тред умер');
      }
      provider.trackerRepository.markAsDead(tab);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        if (event.source == RefreshSource.tracker) {
          provider.trackerRepository.notifyFailedConnectionOnRefresh(tab);
        } else {
          provider.showSnackBar('Проверьте подключение к Интернету.');
        }
      } else {
        if (event.source == RefreshSource.thread) {
          provider.showSnackBar('Неизвестная ошибка Dio');
        }
      }
    } on Exception {
      if (event.source == RefreshSource.thread) {
        provider.showSnackBar('Неизвестная ошибка');
      }
    } finally {
      isBusy = false;
    }
  }

  FutureOr<void> _refreshFromThread() async {
    bool requiresSavingScrollPosition =
        scrollController.hasClients && scrollController.offset != 0;
    if (requiresSavingScrollPosition) {
      scrollService.saveCurrentScrollInfo();
    }

    final int lastIndex = threadRepository.posts.length - 1;
    await threadRepository.refresh();

    isBusy = false;
    add(LoadThreadEvent());

    provider.tabManager.refreshRelatedBranches(tab as ThreadTab, lastIndex);

    await Future.delayed(const Duration(milliseconds: 10));

    if (requiresSavingScrollPosition && threadRepository.newPostsCount > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollService.updateScrollPosition();
      });
    }

    final prefs = await SharedPreferences.getInstance();
    provider.showSnackBar(
        threadRepository.newPostsCount > 0
            ? 'Новых постов: ${threadRepository.newPostsCount}'
            : 'Нет новых постов',
        action: threadRepository.newPostsCount > 0 &&
                (prefs.getBool('showSnackBarActionOnThreadRefresh') ?? true)
            ? SnackBarAction(
                label: 'Показать', onPressed: () => _openEndDrawer())
            : null);

    await provider.trackerRepository.updateThreadByTab(
      tab: tab as ThreadTab,
      posts: threadRepository.postsCount,
      newPosts: 0,
      forceNewPosts: true,
      newReplies: 0,
      forceNewReplies: true,
    );
    provider.trackerCubit.loadTracker();
  }

  FutureOr<void> _refreshFromTracker() async {
    final int lastIndex = threadRepository.posts.length - 1;
    await threadRepository.refresh();

    isBusy = false;
    add(LoadThreadEvent());

    provider.tabManager.refreshRelatedBranches(tab as ThreadTab, lastIndex);

    await Future.delayed(const Duration(milliseconds: 10));

    bool shouldNotifyNewPosts = true;
    if (provider.tabManager.currentTab == tab as ThreadTab &&
        provider.tabManager.isAppInForeground) {
      shouldNotifyNewPosts = false;
    }
    provider.trackerRepository.updateThreadByTab(
      tab: tab as ThreadTab,
      posts: threadRepository.postsCount,
      newPosts: shouldNotifyNewPosts ? threadRepository.newPostsCount : 0,
      forceNewPosts: shouldNotifyNewPosts ? false : true,
      newReplies: threadRepository.newReplies,
      forceNewReplies: shouldNotifyNewPosts ? false : true,
    );
  }

  @override
  void goToPost(TreeNode<Post> node, {required BuildContext context}) {
    final goToPostUseCase = GoToPostUseCase();
    goToPostUseCase(
      GoToPostParams(
        threadRepository: threadRepository,
        currentTab: tab,
        animateToBrowserPage: provider.currentPageIndex == 0
            ? () {
                provider.setCurrentPageIndex(2);
                FocusScope.of(context).unfocus();
              }
            : null,
        node: node,
        dialogStack: dialogStack,
        popUntil: () =>
            Navigator.of(context).popUntil(ModalRoute.withName('/')),
        addTab: (DrawerTab tab) => provider.addTab(tab),
        scrollService: scrollService,
        threadScrollService: scrollService,
        getThreadScrollService: null,
      ),
    );
  }

  void restoreEndDrawerScrollPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (endDrawerScrollController.hasClients) {
        if (endDrawerScrollPosition != null) {
          endDrawerScrollController.jumpTo(endDrawerScrollPosition!);
          return;
        } else {
          endDrawerScrollController.jumpTo(
            endDrawerScrollController.position.maxScrollExtent * 2,
          );
        }
      }
    });
  }

  void storeEndDrawerScrollPosition() {
    endDrawerScrollPosition = endDrawerScrollController.offset;
  }

  void shrinkBranch(TreeNode<Post> node) async {
    node.parent!.expanded = false;

    /// Prevent scrolling if called from [PostPreviewDialog] or [EndDrawer]
    if (dialogStack.isEmpty) {
      scrollService.scrollToNodeInDirection(
          node.parent!.getGlobalKey(threadInfo.opPostId),
          direction: AxisDirection.up);
    }
  }

  void shrinkRootBranch(TreeNode<Post> node) {
    final rootNode = Tree.findRootNode(node);
    rootNode.expanded = false;
    final rootPostKey = rootNode.getGlobalKey(threadInfo.opPostId);

    /// Prevent scrolling if called from [PostPreviewDialog] or [EndDrawer]
    if (dialogStack.isEmpty) {
      scrollService.scrollToNodeInDirection(rootPostKey,
          direction: AxisDirection.up);
    }
  }

  void resetNewPostsCount() {
    provider.trackerRepository.updateThreadByTab(
        tab: tab as ThreadTab,
        posts: null,
        newPosts: 0,
        newReplies: 0,
        forceNewPosts: true,
        forceNewReplies: true);
    provider.trackerCubit.loadTracker();
  }

  @override
  Future<void> close() {
    scrollController.dispose();
    endDrawerScrollController.dispose();
    return super.close();
  }

  void _openEndDrawer() {
    scaffoldKey.currentState!.openEndDrawer();
  }
}

abstract class ThreadEvent {}

class LoadThreadEvent extends ThreadEvent {
  // final bool isRefresh;
  LoadThreadEvent();
}

class RefreshThreadEvent extends ThreadEvent {
  final RefreshSource source;
  RefreshThreadEvent({this.source = RefreshSource.thread});
}

abstract class ThreadState {}

class ThreadInitialState extends ThreadState {}

class ThreadLoadedState extends ThreadState {
  late final List<TreeNode<Post>>? roots;
  late final ThreadInfo threadInfo;
  ThreadLoadedState({required this.roots, required this.threadInfo});
}

class ThreadRefreshingState extends ThreadLoadedState {
  ThreadRefreshingState({required super.roots, required super.threadInfo});
}

class ThreadErrorState extends ThreadState {
  final String message;
  final Exception? exception;
  ThreadErrorState({required this.message, this.exception});
}
