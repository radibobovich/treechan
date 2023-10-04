import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/domain/services/board_list_search_service.dart';
import 'package:treechan/exceptions.dart';
import '../../utils/constants/enums.dart';
import '../../domain/repositories/board_list_repository.dart';
import '../../domain/models/category.dart';

class BoardListBloc extends Bloc<BoardListEvent, BoardListState> {
  late final BoardListRepository _boardListRepository;
  late List<Category> categories;
  late List<Board> favorites;
  late BoardListSearchService searchService;
  foundation.Key key;
  bool allowReorder = false;
  BoardListBloc(
      {required BoardListRepository boardListService, required this.key})
      : _boardListRepository = boardListService,
        super(BoardListInitialState()) {
    on<LoadBoardListEvent>(_load);
    on<RefreshBoardListEvent>(_refresh);
    on<EditFavoritesEvent>(_editFavorites);
    on<SearchQueryChangedEvent>(_searchQueryChanged);
  }

  FutureOr<void> _load(event, emit) async {
    try {
      categories = await _boardListRepository.getCategories();
      favorites = _boardListRepository.getFavoriteBoards();

      emit(BoardListLoadedState(
          categories: categories,
          favorites: favorites,
          allowReorder: allowReorder));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        emit(BoardListErrorState(
            message: "Проверьте подключение к Интернету.",
            exception: NoConnectionException('')));
      } else {
        emit(BoardListErrorState(
            message: "Неизвестная ошибка Dio", exception: e));
      }
    } on Exception catch (e) {
      emit(BoardListErrorState(message: e.toString(), exception: e));
    }
  }

  FutureOr<void> _refresh(event, emit) async {
    try {
      await _boardListRepository.refreshBoardList();
      add(LoadBoardListEvent());
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        emit(BoardListErrorState(
            message: "Проверьте подключение к Интернету.", exception: e));
      } else {
        emit(BoardListErrorState(
            message: "Неизвестная ошибка Dio", exception: e));
      }
    } on Exception catch (e) {
      emit(BoardListErrorState(message: e.toString(), exception: e));
    }
  }

  FutureOr<void> _editFavorites(event, emit) async {
    try {
      if (event.action == FavoriteListAction.add) {
        _boardListRepository.addToFavorites(event.board!);
      } else if (event.action == FavoriteListAction.remove) {
        _boardListRepository.removeFromFavorites(event.board!);
      } else if (event.action == FavoriteListAction.toggleReorder) {
        allowReorder = !allowReorder;
      } else if (event.action == FavoriteListAction.saveAll) {
        _boardListRepository.saveFavoriteBoards(event.favorites!);
      }

      add(LoadBoardListEvent());
    } on Exception catch (e) {
      emit(BoardListErrorState(message: e.toString(), exception: e));
    }
  }

  FutureOr<void> _searchQueryChanged(event, emit) async {
    try {
      searchService =
          BoardListSearchService(boards: _boardListRepository.boards);
      emit(BoardListSearchState(
          searchResult: searchService.search(event.query), query: event.query));
    } on Exception catch (e) {
      emit(BoardListErrorState(message: e.toString(), exception: e));
    }
  }
}

abstract class BoardListEvent {}

class LoadBoardListEvent extends BoardListEvent {}

class RefreshBoardListEvent extends BoardListEvent {}

class EditFavoritesEvent extends BoardListEvent {
  EditFavoritesEvent({this.board, this.favorites, required this.action});
  final Board? board;
  final List<Board>? favorites;
  final FavoriteListAction action;
}

class SearchQueryChangedEvent extends BoardListEvent {
  SearchQueryChangedEvent(this.query);
  final String query;
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

class BoardListSearchState extends BoardListState {
  BoardListSearchState({required this.searchResult, required this.query});
  final List<Board> searchResult;
  final String query;
}

class BoardListErrorState extends BoardListState {
  BoardListErrorState({required this.message, this.exception});
  final String message;
  final Exception? exception;
}
