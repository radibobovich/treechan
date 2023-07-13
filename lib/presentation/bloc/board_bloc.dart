import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/exceptions.dart';
import 'package:treechan/main.dart';
import 'package:treechan/domain/services/board_service.dart';

import '../../utils/constants/enums.dart';
import '../../domain/services/board_search_service.dart';
import '../../domain/models/json/json.dart';
import '../provider/tab_provider.dart';
// import 'tab_bloc.dart';

class BoardBloc extends Bloc<BoardEvent, BoardState> {
  // late final TabBloc tabBloc;
  // late StreamSubscription tabSub;
  late final TabProvider tabProvider;
  late final StreamSubscription tabSub;
  late final BoardService boardService;
  late BoardSearchService searchService;
  final ScrollController scrollController = ScrollController();
  Key key;
  bool isDisposed = false;
  BoardBloc(
      {required this.tabProvider,
      required this.boardService,
      required this.key})
      : super(BoardInitialState()) {
    tabSub = tabProvider.catalogStream.listen((catalog) {
      if (catalog.boardTag == boardService.boardTag && !isDisposed) {
        add(ChangeViewBoardEvent(null, searchTag: catalog.searchTag));
      }
    });

    on<LoadBoardEvent>((event, emit) async {
      try {
        final List<Thread>? threads = await boardService.getThreads();
        searchService = BoardSearchService(threads: threads!);
        emit(BoardLoadedState(
            boardName: boardService.boardName,
            threads: threads,
            completeRefresh: event.refreshCompleted));
      } on BoardNotFoundException {
        emit(BoardErrorState(message: "404 - Доска не найдена"));
      } on FailedResponseException catch (e) {
        emit(BoardErrorState(message: "Ошибка ${e.statusCode}.", exception: e));
      } on NoConnectionException catch (e) {
        emit(BoardErrorState(
            message: 'Проверьте подключение к Интернету.', exception: e));
      } on Exception catch (e) {
        emit(BoardErrorState(message: e.toString(), exception: e));
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
          // emit(BoardErrorState(e.toString()));
          add(LoadBoardEvent(refreshCompleted: false));
        }
      },
    );
    on<ChangeViewBoardEvent>((event, emit) async {
      try {
        await boardService.changeSortType(event.sortType!, event.searchTag);
        add(LoadBoardEvent());
        if (event.searchTag != null) {
          add(SearchQueryChangedEvent(event.searchTag!));
        }
      } on Exception catch (e) {
        emit(BoardErrorState(message: e.toString(), exception: e));
      }
    });
    on<SearchQueryChangedEvent>((event, emit) async {
      try {
        emit(BoardSearchState(
            searchResult: await searchService.search(event.query),
            query: event.query));
      } on Exception catch (e) {
        emit(BoardErrorState(message: e.toString(), exception: e));
      }
    });
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

class RefreshBoardEvent extends BoardEvent {
  RefreshBoardEvent({this.refreshFromScratch = false});
  bool refreshFromScratch;
}

class ChangeViewBoardEvent extends BoardEvent {
  ChangeViewBoardEvent(this.sortType, {this.searchTag}) {
    if (sortType != null && sortType != SortBy.page) {
      prefs.setString('boardSortType', sortType.toString().split('.').last);
    }
    // get sort type from prefs and convert it to enum
    SortBy savedSortType = SortBy.values.firstWhere((e) =>
        e.toString().split('.').last == prefs.getString('boardSortType'));
    sortType ??= savedSortType;
  }
  SortBy? sortType;
  String? searchTag;
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
  BoardLoadedState(
      {required this.boardName, this.threads, this.completeRefresh = true});
}

class BoardSearchState extends BoardState {
  BoardSearchState({required this.searchResult, required this.query});
  final List<Thread> searchResult;
  final String query;
}

class BoardErrorState extends BoardState {
  final String message;
  final Exception? exception;
  BoardErrorState({required this.message, this.exception});
}
