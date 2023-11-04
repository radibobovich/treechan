import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/data/local/hidden_threads_database.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/exceptions.dart';
import 'package:treechan/main.dart';
import 'package:treechan/domain/repositories/board_repository.dart';

import '../../utils/constants/enums.dart';
import '../../domain/services/board_search_service.dart';
import '../provider/page_provider.dart';

class BoardBloc extends Bloc<BoardEvent, BoardState> {
  late final PageProvider tabProvider;
  late final StreamSubscription tabSub;
  late final BoardRepository boardRepository;
  List<int> hiddenThreads = [];
  late BoardSearchService searchService;
  late TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool isBusy = false;
  Key key;
  bool isDisposed = false;
  BoardBloc(
      {required this.tabProvider,
      required this.boardRepository,
      required this.key})
      : super(BoardInitialState()) {
    tabSub = tabProvider.catalogStream.listen((catalog) {
      if (catalog.boardTag == boardRepository.boardTag && !isDisposed) {
        add(ChangeSortBoardEvent(null, query: catalog.searchTag));
      }
    });

    on<LoadBoardEvent>(_load);
    on<ReloadBoardEvent>(_reload);
    on<RefreshBoardEvent>(_refresh);
    on<ChangeSortBoardEvent>(_changeSort);
    on<SearchQueryChangedEvent>(_searchQueryChanged);
  }

  FutureOr<void> _searchQueryChanged(event, emit) async {
    try {
      emit(BoardSearchState(
        searchResult: await searchService.search(event.query),
        query: event.query,
        boardView: (state as dynamic).boardView,
      ));
    } on Exception catch (e) {
      emit(BoardErrorState(message: e.toString(), exception: e));
    }
  }

  FutureOr<void> _changeSort(event, emit) async {
    try {
      bool changed =
          await boardRepository.changeSortType(event.sortType!, event.query);
      if (changed) add(LoadBoardEvent());
      scrollToTop();
      if (event.query != null) {
        Future.delayed(const Duration(milliseconds: 50),
            () => add(SearchQueryChangedEvent(event.query!)));
      }
    } on Exception catch (e) {
      emit(BoardErrorState(message: e.toString(), exception: e));
    }
  }

  FutureOr<void> _refresh(event, emit) async {
    try {
      await boardRepository.refresh();

      add(LoadBoardEvent());
    } catch (e) {
      add(LoadBoardEvent(refreshCompleted: false));
    }
  }

  FutureOr<void> _reload(event, emit) async {
    if (isBusy) return;
    isBusy = true;
    final currentState = state;

    if (currentState is BoardLoadedState) {
      emit(BoardLoadingState(
        boardName: currentState.boardName,
        threads: currentState.threads,
        completeRefresh: false,
        boardView: currentState.boardView,
      ));
    }
    try {
      await boardRepository.load();
      hiddenThreads = await HiddenThreadsDatabase()
          .getHiddenThreadIds(boardRepository.boardTag);
      scrollToTop();
      add(LoadBoardEvent());
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        emit(BoardErrorState(
            message: "Проверьте подключение к Интернету.", exception: e));
      } else {
        emit(BoardErrorState(message: "Неизвестная ошибка Dio", exception: e));
      }
    } on Exception catch (e) {
      emit(BoardErrorState(message: e.toString(), exception: e));
    } finally {
      isBusy = false;
    }
  }

  FutureOr<void> _load(event, emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final BoardView boardView = boardViewFromString(
          prefs.getString('boardView') ?? BoardView.treechan.name);
      hiddenThreads = await HiddenThreadsDatabase()
          .getHiddenThreadIds(boardRepository.boardTag);
      final List<Thread>? threads = await boardRepository.getThreads();
      searchService = BoardSearchService(threads: threads!);
      emit(BoardLoadedState(
        boardName: boardRepository.boardName,
        threads: threads,
        completeRefresh: event.refreshCompleted,
        boardView: boardView,
      ));
    } on BoardNotFoundException {
      emit(BoardErrorState(message: "404 - Доска не найдена"));
    } on NoCookieException {
      emit(BoardErrorState(message: 'Вы не можете просматривать эту доску.'));
    } on FailedResponseException catch (e) {
      emit(BoardErrorState(message: "Ошибка ${e.statusCode}.", exception: e));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        emit(BoardErrorState(
            message: "Проверьте подключение к Интернету.", exception: e));
      } else {
        emit(BoardErrorState(message: "Неизвестная ошибка Dio", exception: e));
      }
    } on Exception catch (e) {
      emit(BoardErrorState(message: e.toString(), exception: e));
    }
  }

  void scrollToTop() {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(0,
        duration: const Duration(milliseconds: 100), curve: Curves.easeOut);
  }

  @override
  Future<void> close() {
    isDisposed = true;
    tabSub.cancel();
    return super.close();
  }
}

abstract class BoardEvent {}

class LoadBoardEvent extends BoardEvent {
  LoadBoardEvent({this.refreshCompleted = true});
  final bool refreshCompleted;
}

class ReloadBoardEvent extends BoardEvent {}

class RefreshBoardEvent extends BoardEvent {}

class ChangeSortBoardEvent extends BoardEvent {
  ChangeSortBoardEvent(this.sortType, {this.query}) {
    if (sortType != null && sortType != SortBy.page) {
      prefs.setString('boardSortType', sortType.toString().split('.').last);
    }
    // get sort type from prefs and convert it to enum
    SortBy savedSortType = SortBy.values.firstWhere((e) =>
        e.toString().split('.').last == prefs.getString('boardSortType'));
    sortType ??= savedSortType;
  }
  SortBy? sortType;
  String? query;
}

class SearchQueryChangedEvent extends BoardEvent {
  SearchQueryChangedEvent(this.query);
  final String query;
}

abstract class BoardState {}

class BoardInitialState extends BoardState {}

class BoardLoadedState extends BoardState {
  final String boardName;
  final List<Thread>? threads;
  final bool completeRefresh;
  final BoardView boardView;
  BoardLoadedState(
      {required this.boardName,
      this.threads,
      this.completeRefresh = true,
      required this.boardView});
}

class BoardLoadingState extends BoardLoadedState {
  BoardLoadingState(
      {required super.boardName,
      required super.threads,
      required super.completeRefresh,
      required super.boardView});
}

class BoardSearchState extends BoardState {
  BoardSearchState(
      {required this.searchResult,
      required this.query,
      required this.boardView});
  final List<Thread> searchResult;
  final String query;
  final BoardView boardView;
}

class BoardErrorState extends BoardState {
  final String message;
  final Exception? exception;
  BoardErrorState({required this.message, this.exception});
}
