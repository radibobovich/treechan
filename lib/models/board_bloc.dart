import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/services/board_service.dart';

import 'board_json.dart';

class BoardBloc extends Bloc<BoardEvent, BoardState> {
  // final String boardTag;
  late final BoardService boardService;
  BoardBloc({required this.boardService}) : super(BoardInitialState()) {
    on<LoadBoardEvent>((event, emit) async {
      try {
        final List<Thread>? threads =
            await boardService.getThreads(SortBy.page, page: 0);
        emit(BoardLoadedState(threads: threads));
      } catch (e) {
        emit(BoardErrorState(e.toString()));
      }
    });
    // TODO: make proper refresh
    on<RefreshBoardEvent>(
      (event, emit) async {
        add(LoadBoardEvent());
      },
    );
  }
}

abstract class BoardEvent {}

class LoadBoardEvent extends BoardEvent {}

class RefreshBoardEvent extends BoardEvent {}

abstract class BoardState {}

class BoardInitialState extends BoardState {}

class BoardLoadedState extends BoardState {
  final List<Thread>? threads;
  BoardLoadedState({required this.threads});
}

class BoardErrorState extends BoardState {
  final String errorMessage;
  BoardErrorState(this.errorMessage);
}
