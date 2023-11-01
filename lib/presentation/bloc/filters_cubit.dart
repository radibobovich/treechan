import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/data/board_list_fetcher.dart';
import 'package:treechan/data/local/filter_database.dart';
import 'package:treechan/di/injection.dart';
import 'package:treechan/domain/models/core/board.dart';
import 'package:treechan/domain/models/db/filter.dart';
import 'package:treechan/utils/constants/enums.dart';

class FiltersCubit extends Cubit<FiltersState> {
  late final FilterDatabase db;
  final FiltersDisplayMode displayMode;
  final Imageboard? imageboard;
  final String? boardTag;
  FiltersCubit({
    required this.displayMode,
    this.imageboard,
    this.boardTag,
  }) : super(AllFiltersInitial());

  void init() async {
    db = await getIt<FilterDb>().instance;
    load();
  }

  void load() async {
    if (displayMode == FiltersDisplayMode.all) {
      final List<FilterWithBoards> filters = await db.getFiltersWithBoards();

      emit(FiltersLoaded(filters: filters));
    } else if (displayMode == FiltersDisplayMode.board) {
      assert(imageboard != null && boardTag != null,
          'Imageboard and board tag should be provided with board display mode');

      final List<FilterView> filters = await db.getFiltersForBoard(
          imageboard: imageboard!, boardTag: boardTag!);

      emit(FiltersLoaded(filters: filters));
    }
  }

  void add(FilterWithBoards filterWithBoards) async {
    await db.addFilter(
        filter: filterWithBoards, boardTags: filterWithBoards.boards);
    load();
  }

  void update(FilterWithBoards oldFilter, FilterWithBoards newFilter) async {
    await db.editFilter(oldFilter, newFilter);
    load();
  }

  Future<FilterWithBoards> getFilterWithBoards(Filter filter) async {
    return (await db.getFiltersWithBoards())
        .firstWhere((element) => element.id == filter.id);
  }

  Future<List<Board>> getBoards(Imageboard imageboard) async {
    final fetcher = BoardListFetcher(imageboard: imageboard);
    return await fetcher.getBoards();
  }

  void remove(int id) async {
    await db.removeFilterById(id);
    load();
  }

  void removeAll() async {
    if (displayMode == FiltersDisplayMode.all) {
      await db.clearAll();
    } else if (displayMode == FiltersDisplayMode.board) {
      await db.removeFiltersByBoardTag(boardTag!, imageboard!);
    }
    load();
  }

  void edit() async {}

  void toggle(int id) async {
    await db.toggleFilterById(id);
    load();
  }

  void toggleAll(bool enabled) async {
    if (displayMode == FiltersDisplayMode.all) {
      await db.toggleAllFilters(enabled);
    } else if (displayMode == FiltersDisplayMode.board) {
      await db.toggleAllFiltersForBoard(enabled,
          imageboard: imageboard!, boardTag: boardTag!);
    }
    load();
  }
}

abstract class FiltersState {}

class AllFiltersInitial extends FiltersState {}

class FiltersLoaded extends FiltersState {
  FiltersLoaded({required this.filters});
  List<Filter> filters;
}
