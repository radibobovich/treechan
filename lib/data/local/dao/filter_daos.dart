import 'package:floor/floor.dart';
import 'package:treechan/domain/models/db/board.dart';
import 'package:treechan/domain/models/db/filter.dart';
import 'package:treechan/domain/models/db/filter_board_relationship.dart';

// part '../../../generated/data/local/dao/filter_daos.g.dart';

@dao
abstract class FilterDao {
  @insert
  Future<int> insertFilter(Filter filter);

  @Query('''SELECT * FROM FilterView''')
  Future<List<FilterView>> getFilters();

  @Query('''SELECT * FROM "$filterDb" WHERE id = :id LIMIT 1''')
  Future<Filter?> getFilterById(int id);

  @Update()
  Future<void> updateFilter(Filter filter);

  @Query('''UPDATE "$filterDb" SET enabled = :enabled
  WHERE imageboard = :imageboard AND tag = :boardTag''')
  Future<void> toggleAllFilters(
      bool enabled, String imageboard, String boardTag);

  /// Relationships in relationship table would be deleted by cascade
  @Query('''DELETE FROM "$filterDb" WHERE id = :id''')
  Future<void> deleteFilterById(int id);

  @Query('''DELETE FROM "$filterDb" WHERE id IN 
    (SELECT $filterReferenceColumn FROM $filterBoardRelationshipDb
    WHERE $boardReferenceColumn = :id)
  AND imageboard = :imageboard''')
  Future<void> deleteFiltersByBoardId(int id, String imageboard);

  @Query('DELETE FROM "$filterDb"')
  Future<void> clear();
}

@dao
abstract class BoardDao {
  @Insert(onConflict: OnConflictStrategy.ignore)
  Future<int> insertBoard(Board board);

  @Query('SELECT * FROM $boardDb WHERE tag = :tag LIMIT 1')
  Future<Board?> findBoardBytag(String tag);

  @Query('DELETE FROM $boardDb')
  Future<void> clear();
}

@dao
abstract class FilterBoardRelationshipDao {
  @insert
  Future<int> insertRelationship(FilterBoardRelationship relationship);

  /// Used for test purposes only.
  @Query('''SELECT * from $filterBoardRelationshipDb''')
  Future<List<FilterBoardRelationship>> getRelationships();

  @Query('''
DELETE FROM $filterBoardRelationshipDb 
WHERE $filterReferenceColumn = :filterId
AND $boardReferenceColumn = :boardId''')
  Future<void> deleteRelationshipByForeignKeys(int filterId, int boardId);

  @Query('DELETE FROM $filterBoardRelationshipDb')
  Future<void> clear();
}
