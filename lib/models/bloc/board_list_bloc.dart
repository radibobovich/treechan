import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/board_list_service.dart';
import '../category.dart';

class BoardListBloc extends Bloc<BoardListEvent, BoardListState> {
  late final BoardListService boardListService;

  BoardListBloc({required this.boardListService})
      : super(BoardListInitialState()) {
    on<LoadBoardListEvent>(
      (event, emit) async {
        try {
          final List<Category> categories =
              await boardListService.getBoardList();
          emit(BoardListLoadedState(categories: categories));
        } catch (e) {
          emit(BoardListErrorState(e.toString()));
        }
      },
    );

    on<RefreshBoardListEvent>(
      (event, emit) async {
        try {
          await boardListService.refreshBoardList();
          add(LoadBoardListEvent());
        } catch (e) {
          emit(BoardListErrorState(e.toString()));
        }
      },
    );
  }
}

abstract class BoardListEvent {}

class LoadBoardListEvent extends BoardListEvent {}

class RefreshBoardListEvent extends BoardListEvent {}

abstract class BoardListState {}

class BoardListInitialState extends BoardListState {}

class BoardListLoadedState extends BoardListState {
  BoardListLoadedState({required this.categories});
  List<Category> categories;
}

class BoardListErrorState extends BoardListState {
  BoardListErrorState(this.errorMessage);
  final String errorMessage;
}
