import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/exceptions.dart';

import '../../services/thread_service.dart';
import '../../models/json/json.dart';

class ThreadBloc extends Bloc<ThreadEvent, ThreadState> {
  late final ThreadService threadService;
  ThreadBloc({required this.threadService}) : super(ThreadInitialState()) {
    on<LoadThreadEvent>(
      (event, emit) async {
        try {
          final roots = await threadService.getRoots();
          final threadInfo = threadService.getThreadInfo;
          emit(ThreadLoadedState(
            roots: roots,
            threadInfo: threadInfo,
          ));
          if (event.isRefresh) {}
        } on ThreadNotFoundException {
          emit(ThreadErrorState("404 - Тред не найден"));
        } on Exception {
          emit(ThreadErrorState("Неизвестная ошибка"));
        }
      },
    );
    on<RefreshThreadEvent>(
      (event, emit) async {
        try {
          // await?
          threadService.refreshThread();
          add(LoadThreadEvent(isRefresh: true));
        } on ThreadNotFoundException {
          emit(ThreadErrorState("404 - Тред умер"));
        } on Exception {
          emit(ThreadErrorState("Неизвестная ошибка"));
        }
      },
    );
  }
}

abstract class ThreadEvent {}

class LoadThreadEvent extends ThreadEvent {
  final bool isRefresh;
  LoadThreadEvent({this.isRefresh = false});
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
  final String errorMessage;
  ThreadErrorState(this.errorMessage);
}
