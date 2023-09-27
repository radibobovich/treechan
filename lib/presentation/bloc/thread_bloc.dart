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

import '../../domain/models/tab.dart';
import '../../domain/models/tree.dart';
import '../../domain/models/json/json.dart';
import '../../domain/repositories/thread_repository.dart';

class ThreadBloc extends Bloc<ThreadEvent, ThreadState> with ThreadBase {
  // final ThreadRepository threadRepository;
  // Key key;
  // final ThreadTab tab;
  // final PageProvider provider;
  final ScrollController endDrawerScrollController = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  // final List<TreeNode<Post>> dialogStack = [];
  double? endDrawerScrollPosition;
  // late final ScrollService scrollService;

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
    on<LoadThreadEvent>(
      (event, emit) async {
        try {
          final roots = await threadRepository.getRoots();
          threadInfo = threadRepository.threadInfo;
          emit(ThreadLoadedState(
            roots: roots,
            threadInfo: threadInfo,
          ));
        } on ThreadNotFoundException catch (e) {
          emit(ThreadErrorState(message: "404 - Тред не найден", exception: e));
        } on NoConnectionException catch (e) {
          emit(ThreadErrorState(
              message: "Проверьте подключение к Интернету.", exception: e));
        } on TreeBuilderTimeoutException catch (e) {
          emit(ThreadErrorState(
              message: "Построение дерева заняло слишком много времени."
                  "Попробуйте открыть тред в классическом режиме.",
              exception: e));
        } on Exception catch (e) {
          emit(ThreadErrorState(message: "Неизвестная ошибка", exception: e));
        }
      },
    );
    on<RefreshThreadEvent>(
      (event, emit) async {
        try {
          //No need to preserve scroll position if the thread hasn't been loaded
          // correctly. This check is created in case user presses refresh after
          // failed thread loading.
          // final int oldPostCount = threadRepository.posts.length;

          if (event.source == RefreshSource.thread &&
              scrollController.hasClients &&
              scrollController.offset != 0) {
            scrollService.saveCurrentScrollInfo();
          }

          final int lastIndex = threadRepository.posts.length - 1;
          await threadRepository.refresh();
          add(LoadThreadEvent());

          provider.tabManager.refreshRelatedBranches(tab, lastIndex);
          await Future.delayed(const Duration(milliseconds: 10));
          if (event.source == RefreshSource.thread &&
              scrollController.hasClients &&
              threadRepository.newPostsCount > 0 &&
              scrollController.offset != 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              scrollService.updateScrollPosition();
            });
          }

          if (event.source == RefreshSource.tracker) {
            provider.trackerRepository.updateThreadByTab(
              tab: tab,
              posts: threadRepository.postsCount,
              newPosts: threadRepository.newPostsCount,
              newReplies: threadRepository.newReplies,
            );
          }
          if (event.source != RefreshSource.tracker) {
            final prefs = await SharedPreferences.getInstance();
            provider.showSnackBar(
                threadRepository.newPostsCount > 0
                    ? 'Новых постов: ${threadRepository.newPostsCount}'
                    : 'Нет новых постов',
                action: threadRepository.newPostsCount > 0 &&
                        (prefs.getBool('showSnackBarActionOnThreadRefresh') ??
                            true)
                    ? SnackBarAction(
                        label: 'Показать', onPressed: () => _openEndDrawer())
                    : null);
          }
        } on ThreadNotFoundException {
          if (event.source != RefreshSource.tracker) {
            provider.showSnackBar('Тред умер');
          }
          provider.trackerRepository.markAsDead(tab);
        } on NoConnectionException {
          if (event.source == RefreshSource.tracker) {
            provider.trackerRepository.notifyFailedConnectionOnRefresh(tab);
          }
        } on Exception catch (e) {
          emit(ThreadErrorState(message: "Неизвестная ошибка", exception: e));
        }
      },
    );
  }

  @override
  void goToPost(TreeNode<Post> node, {required BuildContext? context}) {
    final goToPostUseCase = GoToPostUseCase();
    goToPostUseCase(
      GoToPostParams(
        threadRepository: threadRepository,
        currentTab: tab,
        node: node,
        dialogStack: dialogStack,
        popUntil: context != null
            ? () => Navigator.of(context).popUntil(ModalRoute.withName('/'))
            : () {},
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

class ThreadErrorState extends ThreadState {
  final String message;
  final Exception? exception;
  ThreadErrorState({required this.message, this.exception});
}
