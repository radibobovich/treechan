import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/data/local/history_database.dart';
import 'package:treechan/di/injection.dart';
import 'package:treechan/domain/services/history_search_service.dart';

import '../../domain/models/tab.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  late List<HistoryTab> history;
  late HistorySearchService searchService;
  final List<HistoryTab> _selected = [];

  List<HistoryTab> get selected => _selected;
  HistoryBloc() : super(HistoryInitialState()) {
    on<LoadHistoryEvent>((event, emit) async {
      try {
        history = await getIt<IHistoryDatabase>().getHistory();
        searchService = HistorySearchService(history: history);
        emit(HistoryLoadedState(history: history));
      } catch (e) {
        emit(HistoryErrorState());
      }
    });

    on<SelectionChangedEvent>((event, emit) async {
      if (selected.contains(event.item)) {
        selected.remove(event.item);
      } else {
        selected.add(event.item);
      }
      if (selected.isNotEmpty) {
        if (state is HistoryLoadedState || state is HistorySelectedState) {
          emit(HistorySelectedState(history: history, selected: selected));
        } else if (state is HistorySearchState) {
          emit(HistorySearchSelectedState(
              history: history,
              searchResult: (state as HistorySearchState).searchResult,
              selected: selected));
        } else if (state is HistorySearchSelectedState) {
          emit(HistorySearchSelectedState(
              history: history,
              searchResult: (state as HistorySearchSelectedState).searchResult,
              selected: selected));
        }
      } else {
        if (state is HistorySearchSelectedState) {
          emit(HistorySearchState(
              searchResult:
                  (state as HistorySearchSelectedState).searchResult));
        } else if (state is HistorySelectedState) {
          emit(HistoryLoadedState(history: history));
        }
      }
    });

    on<SearchQueryChangedEvent>((event, emit) async {
      if (state is HistoryLoadedState || state is HistorySearchState) {
        emit(HistorySearchState(
            searchResult: await searchService.search(event.query)));
      } else if (state is HistorySelectedState) {
        emit(HistorySearchSelectedState(
            history: history,
            searchResult: await searchService.search(event.query),
            selected: selected));
      } else if (state is HistorySearchSelectedState) {
        emit(HistorySearchSelectedState(
            history: history,
            searchResult: await searchService.search(event.query),
            selected: selected));
      }
    });

    on<RemoveSelectedEvent>((event, emit) async {
      if (event.removeAll) {
        getIt<IHistoryDatabase>().clear();
        add(LoadHistoryEvent());
        return;
      }
      await getIt<IHistoryDatabase>().removeMultiple(selected);
      _selected.clear();
      add(LoadHistoryEvent());
    });
  }

  void resetSelection() {
    selected.clear();
  }
}

abstract class HistoryEvent {}

class LoadHistoryEvent extends HistoryEvent {}

class SearchQueryChangedEvent extends HistoryEvent {
  SearchQueryChangedEvent(this.query);
  String query;
}

class SelectionChangedEvent extends HistoryEvent {
  SelectionChangedEvent(this.item);
  HistoryTab item;
}

class SearchSelectEvent extends HistoryEvent {
  SearchSelectEvent();
}

class RemoveSelectedEvent extends HistoryEvent {
  RemoveSelectedEvent({this.removeAll = false});
  bool removeAll;
}

abstract class HistoryState {}

class HistoryInitialState extends HistoryState {}

class HistoryLoadedState extends HistoryState {
  HistoryLoadedState({required this.history});
  List<HistoryTab> history;

  void clearHistory() {}
}

class HistorySelectedState extends HistoryState {
  HistorySelectedState({required this.history, required this.selected});
  List<HistoryTab> history;
  List<HistoryTab> selected;
}

class HistorySearchState extends HistoryState {
  HistorySearchState({required this.searchResult});
  List<HistoryTab> searchResult;
}

class HistorySearchSelectedState extends HistoryState {
  HistorySearchSelectedState(
      {required this.history,
      required this.searchResult,
      required this.selected});
  List<HistoryTab> searchResult;
  List<HistoryTab> history;
  List<HistoryTab> selected;
}

class HistoryErrorState extends HistoryState {}
