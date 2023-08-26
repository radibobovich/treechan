import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/domain/models/tab.dart';
import 'package:treechan/domain/services/scroll_service.dart';
import 'package:treechan/exceptions.dart';

import '../../domain/models/tree.dart';
import '../../domain/repositories/thread_repository.dart';
import '../../domain/models/json/json.dart';
import '../provider/page_provider.dart';

class ThreadBloc extends Bloc<ThreadEvent, ThreadState> {
  late final ThreadRepository threadRepository;
  Key key;
  final ThreadTab tab;
  final PageProvider provider;
  final ScrollController scrollController = ScrollController();
  final ScrollController endDrawerScrollController = ScrollController();

  /// Every time new post preview dialog opens the node from which it
  /// has been opened adds here.
  /// Used to check if some post is actually in the current visible tree.
  final List<TreeNode<Post>> dialogStack = [];
  double? endDrawerScrollPosition;
  late final ScrollService scrollService;
  late Root threadInfo;
  ThreadBloc(
      {required this.threadRepository,
      required this.key,
      required this.tab,
      required this.provider})
      : super(ThreadInitialState()) {
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
              message: "Построение дерева заняло слишком много времени. "
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
          final int oldPostCount = threadRepository.posts.length;

          if (oldPostCount > 0 && scrollController.offset != 0) {
            scrollService.saveCurrentScrollInfo();
          }
          final int lastIndex = threadRepository.posts.length - 1;
          await threadRepository.refresh();
          add(LoadThreadEvent());
          provider.refreshRelatedBranches(tab, lastIndex);
          final int newPostCount = threadRepository.posts.length;
          final int postsAdded = newPostCount - oldPostCount;
          await Future.delayed(const Duration(milliseconds: 10));
          if (oldPostCount > 0 &&
              postsAdded > 0 &&
              scrollController.offset != 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              scrollService.updateScrollPosition();
            });
          }

          provider.showSnackBar(postsAdded > 0
              ? 'Новых постов: $postsAdded'
              : 'Нет новых постов');
        } on ThreadNotFoundException {
          // emit(ThreadErrorState(message: "404 - Тред умер", exception: e));
          provider.showSnackBar('Тред умер');
        } on NoConnectionException {
          // do nothing
        } on Exception catch (e) {
          emit(ThreadErrorState(message: "Неизвестная ошибка", exception: e));
        }
      },
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
          node.parent!.getGlobalKey(threadInfo.opPostId!),
          direction: AxisDirection.up);
    }
  }

  void shrinkRootBranch(TreeNode<Post> node) {
    final rootNode = Tree.findRootNode(node);
    rootNode.expanded = false;
    final rootPostKey = rootNode.getGlobalKey(threadInfo.opPostId!);

    /// Prevent scrolling if called from [PostPreviewDialog] or [EndDrawer]
    if (dialogStack.isEmpty) {
      scrollService.scrollToNodeInDirection(rootPostKey,
          direction: AxisDirection.up);
    }
  }
}

abstract class ThreadEvent {}

class LoadThreadEvent extends ThreadEvent {
  // final bool isRefresh;
  LoadThreadEvent();
}

class RefreshThreadEvent extends ThreadEvent {}

abstract class ThreadState {}

class ThreadInitialState extends ThreadState {}

class ThreadLoadedState extends ThreadState {
  late final List<TreeNode<Post>>? roots;
  late final Root? threadInfo;
  ThreadLoadedState({required this.roots, required this.threadInfo});
}

class ThreadErrorState extends ThreadState {
  final String message;
  final Exception? exception;
  ThreadErrorState({required this.message, this.exception});
}
