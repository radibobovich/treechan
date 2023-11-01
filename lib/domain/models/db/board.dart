import 'package:floor/floor.dart';

const String boardDb = 'Board';

@Entity(tableName: boardDb, indices: [
  Index(value: ['tag'], unique: true)
])
class Board {
  @PrimaryKey(autoGenerate: true)
  int? id;
  final String tag;

  Board({required this.id, required this.tag});
}
