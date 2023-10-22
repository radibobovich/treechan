import 'dart:async';
import 'package:floor/floor.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:treechan/data/local/dao/filter_daos.dart';

import 'package:treechan/domain/models/db/board.dart';
import 'package:treechan/domain/models/db/filter.dart';
import 'package:treechan/domain/models/db/filter_board_relationship.dart';
import 'package:treechan/utils/constants/enums.dart';

part '../../generated/data/local/filter_database.g.dart';

/// A database that manages autohide filters.
///
/// [FilterBoardRelationship] contains rows that has [Filter] reference id
/// and [Board] reference id so multiple filters can have the same board
/// they are applied to, and one filter can have multiple boards the filter
/// applied to.
/// Rows are getting deleted from [FilterBoardRelationship] automatically
/// once a parent row from [Filter] is deleted.
@Database(
    version: 1,
    entities: [Filter, Board, FilterBoardRelationship],
    views: [FilterView])
abstract class FilterDatabase extends FloorDatabase {
  FilterDao get filterDao;
  BoardDao get boardDao;
  FilterBoardRelationshipDao get relationshipDao;

  Future<int> addFilter({
    required Filter filter,
    required List<String> boardTags,
  }) async {
    final filterId = await filterDao.insertFilter(filter);
    for (String tag in boardTags) {
      int boardId = await boardDao.insertBoard(Board(id: null, tag: tag));

      /// if the board already exists then get its index
      if (boardId == 0) {
        boardId = (await boardDao.findBoardBytag(tag))!.id!;
      }
      final relationship = FilterBoardRelationship(
        filterReference: filterId,
        boardReference: boardId,
      );
      await relationshipDao.insertRelationship(relationship);
    }
    return filterId;
  }

  /// Returns all filters that are created for specific board and imageboard.
  Future<List<FilterView>> getFiltersForBoard(
      {required Imageboard imageboard, required String boardTag}) async {
    final List<FilterView> filters = [];

    final String query =
        '''SELECT "$filterDb".id, enabled, name, pattern, imageboard, $boardDb.tag
FROM "$filterDb"
INNER JOIN $boardDb ON $filterBoardRelationshipDb.$boardReferenceColumn = $boardDb.id
INNER JOIN $filterBoardRelationshipDb ON "$filterDb".id = $filterBoardRelationshipDb.$filterReferenceColumn
  WHERE tag = "$boardTag"
  AND imageboard = "${imageboard.name}"
  ''';
    final List<Map<String, Object?>> maps = await database.rawQuery(query);

    for (var map in maps) {
      filters.add(FilterView.fromMap(map));
    }
    return filters;
  }

  /// Returns all filters, each of which has a list of boards that it can be
  /// applied to.
  Future<List<FilterWithBoards>> getFiltersWithBoards() async {
    final List<FilterView> rawFilters = await filterDao.getFilters();
    if (rawFilters.isEmpty) return [];

    final List<FilterWithBoards> filters = [];

    int prevId = 0;
    FilterWithBoards filter = FilterWithBoards.fromFilterView(rawFilters.first);
    if (rawFilters.length == 1) return [filter];

    /// [FilterView] objects have only one board tag in the row, and for each
    /// tag we have a separate row. So we need to reduce these objects
    /// to the list of [FilterWithBoards] objects, each of which has a list
    /// of related tags.
    for (int i = 0; i < rawFilters.length; i++) {
      if (rawFilters[i].id == prevId) {
        filter.boards.add(rawFilters[i].tag);
      } else {
        if (i != 0) filters.add(filter.copyWith());
        filter = FilterWithBoards.fromFilterView(rawFilters[i]);
        prevId = rawFilters[i].id!;
      }
    }

    /// Last filter with different board tag won't be added by loop
    filters.add(filter);

    return filters;
  }

  /// Updates flter with new properties.
  ///
  /// If boards list has been changed, updates relationship table accordingly.
  Future<void> editFilter(
      FilterWithBoards oldFilter, FilterWithBoards newFilter) async {
    final filterId = oldFilter.id!;
    if (!listEquals(oldFilter.boards, newFilter.boards)) {
      final oldBoards = oldFilter.boards.toSet();
      final newBoards = newFilter.boards.toSet();

      final addedBoards = newBoards.difference(oldBoards);
      final removedBoards = oldBoards.difference(newBoards);

      for (var board in addedBoards) {
        int? boardId = (await boardDao.findBoardBytag(board))?.id;
        boardId ??= await boardDao.insertBoard(Board(id: null, tag: board));

        await relationshipDao.insertRelationship(FilterBoardRelationship(
            filterReference: filterId, boardReference: boardId));
      }

      for (var board in removedBoards) {
        final boardId = (await boardDao.findBoardBytag(board))?.id;
        if (boardId == null) throw Exception('Board not found');

        await relationshipDao.deleteRelationshipByForeignKeys(
            filterId, boardId);
      }
    }

    final filter = Filter(
      id: filterId,
      enabled: newFilter.enabled,
      imageboard: newFilter.imageboard,
      name: newFilter.name,
      pattern: newFilter.pattern,
    );
    await filterDao.updateFilter(filter);
  }

  /// Performs filter edit if it was called from specific board filter list.
  ///
  /// Worth noting that if filter has multiple boards, changes will be applied
  /// to all the boards (this method only edits filter row in filters table)
  Future<void> editBoardFilter(
      FilterView oldFilter, FilterView newFilter) async {
    final Filter filter = Filter.fromFilterView(newFilter);
    await filterDao.updateFilter(filter);
  }

  /// Toggles enabled property of the [Filter].
  ///
  /// Returns new value of the property or null if the filter not found.
  Future<bool?> toggleFilterById(int id) async {
    final filter = await filterDao.getFilterById(id);
    if (filter == null) return null;
    await filterDao.updateFilter(filter..enabled = !filter.enabled);
    return filter.enabled;
  }

  /// Sets all filters enabled property to boolean provided.
  Future<void> toggleAllFilters(bool enabled,
      {required Imageboard imageboard, required String boardTag}) async {
    await filterDao.toggleAllFilters(enabled, imageboard.name, boardTag);
  }

  Future<void> removeFilterById(int id) async {
    await filterDao.deleteFilterById(id);
  }

  Future<void> removeFiltersByBoardTag(
      String tag, Imageboard imageboard) async {
    final board = await boardDao.findBoardBytag(tag);
    if (board == null) return;

    await filterDao.deleteFiltersByBoardId(board.id!, imageboard.name);
  }

  Future<void> clearAll() async {
    await relationshipDao.clear();
    await boardDao.clear();
    await filterDao.clear();
  }
}
