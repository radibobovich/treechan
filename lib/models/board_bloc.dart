import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/services/board_service.dart';

import '../models/json/json.dart';

class BoardBloc extends Bloc<BoardEvent, BoardState> {
  // final String boardTag;
  late final BoardService boardService;
  BoardBloc({required this.boardService}) : super(BoardInitialState()) {
    on<LoadBoardEvent>((event, emit) async {
      try {
        final List<Thread>? threads = await boardService.getThreads();
        emit(BoardLoadedState(threads: threads));
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
          emit(BoardErrorState(e.toString()));
        }
      },
    );
  }
}

abstract class BoardEvent {}

class LoadBoardEvent extends BoardEvent {}

class RefreshBoardEvent extends BoardEvent {
  RefreshBoardEvent({this.refreshFromScratch = false});
  bool refreshFromScratch;
}

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
