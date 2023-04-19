import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/exceptions.dart';

import '../../domain/services/thread_service.dart';
import '../../domain/models/json/json.dart';

class ThreadBloc extends Bloc<ThreadEvent, ThreadState> {
  late final ThreadService threadService;
  // late List<TreeNode<Post>>? roots;
  late Root? threadInfo;
  ThreadBloc({required this.threadService}) : super(ThreadInitialState()) {
    on<LoadThreadEvent>(
      (event, emit) async {
        try {
          final roots = await threadService.getRoots();
          threadInfo = threadService.getThreadInfo;
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
    // on<OpenCatalogEvent>(
    //   (event, emit) async {
    //     emit(OpenCatalogState(
    //         boardTag: event.boardTag, searchTag: event.searchTag));
    //   },
    // );
  }
}

abstract class ThreadEvent {}

class LoadThreadEvent extends ThreadEvent {
  final bool isRefresh;
  LoadThreadEvent({this.isRefresh = false});
}

class RefreshThreadEvent extends ThreadEvent {}

// class OpenCatalogEvent extends ThreadEvent {
//   OpenCatalogEvent({required this.boardTag, required this.searchTag});
//   final String boardTag;
//   final String searchTag;
// }

abstract class ThreadState {}

class ThreadInitialState extends ThreadState {}

class ThreadLoadedState extends ThreadState {
  late final List<TreeNode<Post>>? roots;
  late final Root? threadInfo;
  ThreadLoadedState({required this.roots, required this.threadInfo});
}

// class OpenCatalogState extends ThreadState {
//   OpenCatalogState({required this.boardTag, required this.searchTag});
//   final String boardTag;
//   final String searchTag;
// }

class ThreadErrorState extends ThreadState {
  final String errorMessage;
  ThreadErrorState(this.errorMessage);
}
