import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treechan/data/local/filter_database.dart';
import 'package:treechan/domain/models/db/filter.dart';
import 'package:treechan/utils/constants/enums.dart';

/// TODO: group and add expect everywhere
void main() {
  test('Drop all tables', () async {
    final db = await $FloorFilterDatabase
        .databaseBuilder('filter_database.db')
        .build();

    await db.clearAll();
  });

  group('Insert and fetch', () {
    test('Filter insert and fetch', () async {
      final db = await $FloorFilterDatabase
          .databaseBuilder('filter_database.db')
          .build();

      await db.clearAll();

      final filter = Filter(
        id: null,
        enabled: true,
        imageboard: Imageboard.dvach.name,
        name: 'filter1',
        pattern: 'test',
        caseSensitive: false,
      );
      final List<String> tags = ['b', 'bo'];

      await db.addFilter(filter: filter, boardTags: tags);

      final List<FilterView> filters = await db.getFiltersForBoard(
          imageboard: Imageboard.dvach, boardTag: 'bo');
      debugPrint(filters.toString());

      final FilterView expectedFilter = FilterView(
        tag: 'bo',
        id: -1,
        enabled: true,
        imageboard: 'dvach',
        name: 'filter1',
        pattern: 'test',
        caseSensitive: false,
      );
      expect(filters.length, 1, reason: 'Expected one filter');
      expect(filters.first, expectedFilter, reason: "Filter doesn't match");
    });

    /// Should be executed after filter insert test
    test('Filter insert with overlapping boards', () async {
      final db = await $FloorFilterDatabase
          .databaseBuilder('filter_database.db')
          .build();

      final filter = Filter(
        id: null,
        enabled: true,
        imageboard: Imageboard.dvach.name,
        name: 'filter2',
        pattern: 'test',
        caseSensitive: false,
      );
      final List<String> tags = ['b', 'pr'];

      await db.addFilter(filter: filter, boardTags: tags);

      final List<FilterView> filters = await db.getFiltersForBoard(
          imageboard: Imageboard.dvach, boardTag: 'b');
      debugPrint(filters.toString());

      final FilterView expectedFilter1 = FilterView(
        tag: 'b',
        id: -1,
        enabled: true,
        imageboard: 'dvach',
        name: 'filter1',
        pattern: 'test',
        caseSensitive: false,
      );
      final FilterView expectedFilter2 = FilterView(
        tag: 'b',
        id: -1,
        enabled: true,
        imageboard: 'dvach',
        name: 'filter2',
        pattern: 'test',
        caseSensitive: false,
      );

      expect(filters.length, 2, reason: 'Expected two filters');
      expect(filters.first, expectedFilter1,
          reason: "First filter doesn't match");
      expect(filters.last, expectedFilter2,
          reason: "Second filter doesn't match");
    });

    test('Get all filters with board list', () async {
      final db = await $FloorFilterDatabase
          .databaseBuilder('filter_database.db')
          .build();

      final List<FilterWithBoards> filters = await db.getFiltersWithBoards();
      debugPrint(filters.toString());

      final expectedFilter1 = FilterWithBoards(
        ['b', 'bo'],
        id: -1,
        enabled: true,
        imageboard: 'dvach',
        name: 'filter1',
        pattern: 'test',
        caseSensitive: false,
      );

      final expectedFilter2 = FilterWithBoards(
        ['b', 'pr'],
        id: -1,
        enabled: true,
        imageboard: 'dvach',
        name: 'filter2',
        pattern: 'test',
        caseSensitive: false,
      );

      expect(filters.length, 2, reason: 'Expected two filters');
      expect(filters.first, expectedFilter1);
      expect(filters.last, expectedFilter2);
    });
  });
  group('Deletion', () {
    test('Delete filter by id', () async {
      final db = await $FloorFilterDatabase
          .databaseBuilder('filter_database.db')
          .build();
      await db.clearAll();

      final filter = Filter(
        id: null,
        enabled: true,
        imageboard: Imageboard.dvach.name,
        name: 'filter2',
        pattern: 'test',
        caseSensitive: false,
      );
      final List<String> tags = ['b', 'pr'];
      final filterId = await db.addFilter(filter: filter, boardTags: tags);

      await db.removeFilterById(filterId);

      final filters = await db.getFiltersWithBoards();
      expect(filters, isEmpty);
    });

    test('Delete filters by board tag', () async {
      final db = await $FloorFilterDatabase
          .databaseBuilder('filter_database.db')
          .build();
      await db.clearAll();

      final filter1 = Filter(
          id: null,
          enabled: true,
          imageboard: Imageboard.dvach.name,
          name: 'filter1',
          pattern: 'test',
          caseSensitive: false);
      final List<String> tags1 = ['b', 'bo'];
      await db.addFilter(filter: filter1, boardTags: tags1);

      final filter2 = Filter(
          id: null,
          enabled: true,
          imageboard: Imageboard.dvach.name,
          name: 'filter2',
          pattern: 'test',
          caseSensitive: false);
      final List<String> tags2 = ['b', 'pr'];
      await db.addFilter(filter: filter2, boardTags: tags2);

      await db.removeFiltersByBoardTag('b', Imageboard.dvach);

      final filters = await db.getFiltersWithBoards();

      /// Expected to get the same filters but without b boards
      expect(filters.length, 2, reason: 'Expected two filters');

      final filter1Boards = filters.first.boards;
      final filter2Boards = filters.last.boards;

      expect(listEquals(filter1Boards, ['bo']), true,
          reason:
              "First filter boards list hasn't been updated correctly. Expected: ['bo']; Got: $filter1Boards");
      expect(listEquals(filter2Boards, ['pr']), true,
          reason:
              "Second filter boards list hasn't been updated correctly. Expected: ['pr']; Got: $filter2Boards");
    });
  });

  group('Edit', () {
    test('Edit filter boards', () async {
      final db = await $FloorFilterDatabase
          .databaseBuilder('filter_database.db')
          .build();
      await db.clearAll();

      final filter = Filter(
        id: null,
        enabled: true,
        imageboard: Imageboard.dvach.name,
        name: 'filter1',
        pattern: 'test',
        caseSensitive: false,
      );
      final List<String> tags = ['b', 'bo'];
      final filterId = await db.addFilter(filter: filter, boardTags: tags);

      final filters = await db.getFiltersWithBoards();
      expect(filters.length, 1, reason: 'Expected one filter before edit');

      /// Remove /b/ and add /s/
      await db.editFilter(
          filters.first, filters.first.copyWith(boards: ['bo', 's']));

      final newFilters = await db.getFiltersWithBoards();
      expect(newFilters.length, 1, reason: 'Expected one filter after edit');

      final relationships = await db.relationshipDao.getRelationships();
      debugPrint(relationships.toString());

      expect(relationships.length, 2, reason: 'Expected two relationships');
      final int bo = (await db.boardDao.findBoardBytag('bo'))!.id!;
      final int s = (await db.boardDao.findBoardBytag('s'))!.id!;

      expect(relationships.first.boardReference, bo,
          reason: 'Wrong first relationship board ref');
      expect(relationships.first.filterReference, filterId,
          reason: 'Wrong first relationship filter ref');

      expect(relationships.last.boardReference, s);
      expect(relationships.last.filterReference, filterId);
    });

    test('Edit one board filter', () async {
      final db = await $FloorFilterDatabase
          .databaseBuilder('filter_database.db')
          .build();
      await db.clearAll();

      final filter = Filter(
          id: null,
          enabled: true,
          imageboard: Imageboard.dvach.name,
          name: 'filter1',
          pattern: 'test',
          caseSensitive: false);
      final List<String> tags = ['b', 'bo'];
      await db.addFilter(filter: filter, boardTags: tags);

      final filterViews = await db.getFiltersForBoard(
          imageboard: Imageboard.dvach, boardTag: 'b');
      expect(filterViews.length, 1, reason: 'Expected one filter');

      final newFilter =
          filterViews.first.copyWith(name: 'filter2', pattern: 'test_edited');
      await db.editBoardFilter(filterViews.first, newFilter);

      final newFilterViews = await db.getFiltersForBoard(
          imageboard: Imageboard.dvach, boardTag: 'b');
      expect(newFilterViews.length, 1, reason: 'Expected one filter');
      expect(newFilterViews.first.name, 'filter2',
          reason: 'Expected name changed');
      expect(newFilterViews.first.pattern, 'test_edited',
          reason: 'Expected pattern changed');
    });
  });
}
