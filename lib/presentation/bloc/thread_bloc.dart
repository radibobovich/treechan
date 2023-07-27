import 'dart:ui';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/domain/models/tab.dart';
import 'package:treechan/domain/services/scroll_service.dart';
import 'package:treechan/exceptions.dart';

import '../../domain/services/thread_service.dart';
import '../../domain/models/json/json.dart';
import '../provider/tab_provider.dart';

class ThreadBloc extends Bloc<ThreadEvent, ThreadState> {
  late final ThreadService threadService;
  Key key;
  final DrawerTab tab;
  final TabProvider provider;
  final ScrollController scrollController = ScrollController();
  late final ScrollService scrollService;
  late Root? threadInfo;
  ThreadBloc(
      {required this.threadService,
      required this.key,
      required this.tab,
      required this.provider})
      : super(ThreadInitialState()) {
    scrollService = ScrollService(scrollController,
        (window.physicalSize / window.devicePixelRatio).width);
    on<LoadThreadEvent>(
      (event, emit) async {
        try {
          final roots = await threadService.getRoots();
          threadInfo = threadService.getThreadInfo;
          emit(ThreadLoadedState(
            roots: roots,
            threadInfo: threadInfo,
          ));
        } on ThreadNotFoundException catch (e) {
          emit(ThreadErrorState(message: "404 - Тред не найден", exception: e));
        } on NoConnectionException catch (e) {
          emit(ThreadErrorState(
              message: "Проверьте подключение к Интернету.", exception: e));
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
          int oldPostCount = threadService.getPosts.length;

          if (oldPostCount > 0 && scrollController.offset != 0) {
            scrollService.saveCurrentScrollInfo();
          }
          int lastIndex = threadService.getPosts.length - 1;
          await threadService.refresh();
          add(LoadThreadEvent());
          provider.refreshRelatedBranches(tab, lastIndex);
          int newPostCount = threadService.getPosts.length;

          await Future.delayed(const Duration(milliseconds: 10));

          if (oldPostCount > 0 &&
              newPostCount > oldPostCount &&
              scrollController.offset != 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              scrollService.updateScrollPosition();
            });
          }
        } on ThreadNotFoundException catch (e) {
          emit(ThreadErrorState(message: "404 - Тред умер", exception: e));
        } on NoConnectionException {
          // do nothing
          // TODO: show error snackbar
        } on Exception catch (e) {
          emit(ThreadErrorState(message: "Неизвестная ошибка", exception: e));
        }
      },
    );
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
