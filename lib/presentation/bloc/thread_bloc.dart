import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/exceptions.dart';

import '../../domain/services/thread_service.dart';
import '../../domain/models/json/json.dart';

class ThreadBloc extends Bloc<ThreadEvent, ThreadState> {
  late final ThreadService threadService;
  Key key;
  // late List<TreeNode<Post>>? roots;
  late Root? threadInfo;
  ThreadBloc({required this.threadService, required this.key})
      : super(ThreadInitialState()) {
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
          await threadService.refresh();
          add(LoadThreadEvent());
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
