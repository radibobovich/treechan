import 'package:floor/floor.dart';
import 'package:treechan/domain/models/db/board.dart';
import 'package:treechan/domain/models/db/filter.dart';

const String filterReferenceColumn = 'filter_reference';
const String boardReferenceColumn = 'board_reference';
const String _id = 'id';

const String filterBoardRelationshipDb = 'FilterBoardRelationship';

@Entity(
  tableName: filterBoardRelationshipDb,
  foreignKeys: [
    ForeignKey(
      childColumns: [filterReferenceColumn],
      parentColumns: [_id],
      entity: Filter,
      onDelete: ForeignKeyAction.cascade,
    ),
    ForeignKey(
      childColumns: [boardReferenceColumn],
      parentColumns: [_id],
      entity: Board,
      onDelete: ForeignKeyAction.noAction,
    )
  ],
)
class FilterBoardRelationship {
  @PrimaryKey(autoGenerate: true)
  int? id;
  @ColumnInfo(name: filterReferenceColumn)
  final int filterReference;
  @ColumnInfo(name: boardReferenceColumn)
  final int boardReference;

  FilterBoardRelationship(
      {required this.id,
      required this.filterReference,
      required this.boardReference});

  @override
  String toString() {
    return 'id: $id, filterId: $filterReference, boardId: $boardReference\n';
  }
}
