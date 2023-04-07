import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/board_list_service.dart';
import '../category.dart';
import '../json/board_json.dart';

class BoardListBloc extends Bloc<BoardListEvent, BoardListState> {
  late final BoardListService _boardListService;
  late List<Category> categories;
  late List<Board> favorites;
  bool allowReorder = false;
  BoardListBloc({required BoardListService boardListService})
      : _boardListService = boardListService,
        super(BoardListInitialState()) {
    on<LoadBoardListEvent>(
      (event, emit) async {
        try {
          categories = await _boardListService.getCategories();
          favorites = _boardListService.getFavoriteBoards();
          emit(BoardListLoadedState(
              categories: categories,
              favorites: favorites,
              allowReorder: allowReorder));
        } catch (e) {
          emit(BoardListErrorState(e.toString()));
        }
      },
    );

    on<RefreshBoardListEvent>(
      (event, emit) async {
        try {
          await _boardListService.refreshBoardList();
          add(LoadBoardListEvent());
        } catch (e) {
          emit(BoardListErrorState(e.toString()));
        }
      },
    );
    on<EditFavoritesEvent>(
      (event, emit) async {
        try {
          if (event.action == FavoriteListAction.add) {
            _boardListService.addToFavorites(event.board!);
          } else if (event.action == FavoriteListAction.remove) {
            _boardListService.removeFromFavorites(event.board!);
          } else if (event.action == FavoriteListAction.toggleReorder) {
            allowReorder = !allowReorder;
          } else if (event.action == FavoriteListAction.saveAll) {
            _boardListService.saveFavoriteBoards(event.favorites!);
          }

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

enum FavoriteListAction { add, remove, toggleReorder, saveAll }

class EditFavoritesEvent extends BoardListEvent {
  EditFavoritesEvent({this.board, this.favorites, required this.action});
  final Board? board;
  final List<Board>? favorites;
  final FavoriteListAction action;
}

abstract class BoardListState {}

class BoardListInitialState extends BoardListState {}

class BoardListLoadedState extends BoardListState {
  BoardListLoadedState(
      {required this.categories,
      required this.favorites,
      required this.allowReorder});
  List<Category> categories;
  List<Board> favorites;
  bool allowReorder;
}

class BoardListErrorState extends BoardListState {
  BoardListErrorState(this.errorMessage);
  final String errorMessage;
}
