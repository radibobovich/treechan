import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/exceptions.dart';
import 'package:treechan/main.dart';
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
      } on BoardNotFoundException {
        emit(BoardErrorState("404 - Доска не найдена"));
      } on Exception {
        emit(BoardErrorState("Неизвестная ошибка"));
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
    on<ChangeViewBoardEvent>((event, emit) async {
      try {
        await boardService.changeSortType(event.sortType!, event.searchTag);
        add(LoadBoardEvent());
      } catch (e) {
        emit(BoardErrorState(e.toString()));
      }
    });
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

class ChangeViewBoardEvent extends BoardEvent {
  ChangeViewBoardEvent(this.sortType, {this.searchTag}) {
    // get sort type from prefs and convert it to enum
    SortBy boardSortType = SortBy.values.firstWhere((e) =>
        e.toString().split('.').last == prefs.getString('boardSortType'));
    sortType ??= boardSortType;
  }
  SortBy? sortType;
  String? searchTag;
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
