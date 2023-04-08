import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/services/board_service.dart';

import '../json/json.dart';

class BoardBloc extends Bloc<BoardEvent, BoardState> {
  // final String boardTag;
  late final BoardService boardService;
  BoardBloc({required this.boardService}) : super(BoardInitialState()) {
    on<LoadBoardEvent>((event, emit) async {
      try {
        final List<Thread>? threads = await boardService.getThreads();
        emit(BoardLoadedState(
            boardName: boardService.boardName,
            threads: threads,
            completeRefresh: event.refreshCompleted));
      } catch (e) {
        emit(BoardErrorState(e.toString()));
      }
    });
    on<RefreshBoardEvent>(
      (event, emit) async {
        try {
          if (event.refreshFromScratch) {
            await boardService.loadBoard();
          } else {
            await boardService.refreshBoard();
          }
          add(LoadBoardEvent());
        } catch (e) {
          boardService.currentPage -= 1;
          // emit(BoardErrorState(e.toString()));
          add(LoadBoardEvent(refreshCompleted: false));
        }
      },
    );
  }
}

abstract class BoardEvent {}

class LoadBoardEvent extends BoardEvent {
  LoadBoardEvent({this.refreshCompleted = true});
  final bool refreshCompleted;
}

class RefreshBoardEvent extends BoardEvent {
  RefreshBoardEvent({this.refreshFromScratch = false});
  bool refreshFromScratch;
}

abstract class BoardState {}

class BoardInitialState extends BoardState {}

class BoardLoadedState extends BoardState {
  final String boardName;
  final List<Thread>? threads;
  final bool completeRefresh;
  BoardLoadedState(
      {required this.boardName, this.threads, this.completeRefresh = true});
}

// class RefreshCompletedState extends BoardState {
//   RefreshCompletedState();
// }

class BoardErrorState extends BoardState {
  final String errorMessage;
  BoardErrorState(this.errorMessage);
}
