import 'package:floor/floor.dart';
import 'package:flutter/foundation.dart';
import 'package:treechan/domain/models/db/board.dart';
import 'package:treechan/domain/models/db/filter_board_relationship.dart';

const String filterDb = 'Filter';

@Entity(tableName: filterDb)
class Filter {
  @PrimaryKey(autoGenerate: true)
  int? id;
  bool enabled;
  final String imageboard;
  final String name;
  final String pattern;
  final bool caseSensitive;

  Filter(
      {required this.id,
      required this.enabled,
      required this.imageboard,
      required this.name,
      required this.pattern,
      required this.caseSensitive});

  @override
  String toString() {
    return 'Imageboard: $imageboard, name: $name, pattern: $pattern, enabled: $enabled\n';
  }

  Filter.fromMap(Map<String, Object?> map)
      : id = (map['id'] as int?),
        enabled = (map['enabled'] as int) == 1,
        imageboard = map['imageboard'] as String,
        name = map['name'] as String,
        pattern = map['pattern'] as String,
        caseSensitive = (map['caseSensitive'] as int) == 1;

  Filter.fromFilterView(FilterView filterView)
      : enabled = filterView.enabled,
        id = filterView.id,
        name = filterView.name,
        pattern = filterView.pattern,
        caseSensitive = filterView.caseSensitive,
        imageboard = filterView.imageboard;
}

class FilterWithBoards extends Filter {
  final List<String> boards;
  FilterWithBoards(this.boards,
      {required super.id,
      required super.enabled,
      required super.imageboard,
      required super.name,
      required super.pattern,
      required super.caseSensitive});

  FilterWithBoards.fromFilterView(FilterView filterView)
      : boards = [filterView.tag],
        super.fromFilterView(filterView);

  FilterWithBoards copyWith(
      {List<String>? boards,
      int? id,
      bool? enabled,
      String? imageboard,
      String? name,
      String? pattern,
      bool? caseSensitive}) {
    return FilterWithBoards(
        id: id ?? this.id,
        boards ?? this.boards,
        enabled: enabled ?? this.enabled,
        imageboard: imageboard ?? this.imageboard,
        name: name ?? this.name,
        pattern: pattern ?? this.pattern,
        caseSensitive: caseSensitive ?? this.caseSensitive);
  }

  @override
  String toString() {
    return 'Imageboard: $imageboard, name: $name, pattern: $pattern, enabled: $enabled\nboards: $boards\n';
  }

  String get boardsEnumeration {
    return boards
        .toString()
        .substring(1, boards.toString().length - 1)
        .trimRight();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FilterWithBoards &&
        listEquals(boards, other.boards) &&
        enabled == other.enabled &&
        imageboard == other.imageboard &&
        name == other.name &&
        pattern == other.pattern;
  }

  @override
  int get hashCode =>
      boards.hashCode ^
      enabled.hashCode ^
      imageboard.hashCode ^
      name.hashCode ^
      pattern.hashCode;
}

// @DatabaseView(
//     ''' SELECT * FROM "$filterDb"
//   INNER JOIN $boardDb ON $filterBoardRelationshipDb.$boardReferenceColumn = $boardDb.id
// INNER JOIN $filterBoardRelationshipDb ON "$filterDb.id" = $filterBoardRelationshipDb.$filterReferenceColumn''')

/// Used to get all filters with their tags and also for raw query
@DatabaseView('''
SELECT "$filterDb".*, $boardDb.tag
FROM "$filterDb"
LEFT JOIN $filterBoardRelationshipDb ON "$filterDb".id = $filterBoardRelationshipDb.$filterReferenceColumn
LEFT JOIN $boardDb ON $filterBoardRelationshipDb.$boardReferenceColumn = $boardDb.id
ORDER BY "$filterDb".id ASC
''')
class FilterView extends Filter {
  FilterView({
    required this.tag,
    required super.id,
    required super.enabled,
    required super.imageboard,
    required super.name,
    required super.pattern,
    required super.caseSensitive,
  });
  final String tag;

  FilterView.fromMap(Map<String, Object?> map)
      : tag = map['tag'] as String,
        super.fromMap(map);

  @override
  String toString() {
    return 'Tag: $tag, Imageboard: $imageboard, name: $name, pattern: $pattern, enabled: $enabled\n';
  }

  FilterView copyWith(
      {String? tag,
      int? id,
      bool? enabled,
      String? imageboard,
      String? name,
      String? pattern,
      bool? caseSensitive}) {
    return FilterView(
      tag: tag ?? this.tag,
      id: id ?? this.id,
      enabled: enabled ?? this.enabled,
      imageboard: imageboard ?? this.imageboard,
      name: name ?? this.name,
      pattern: pattern ?? this.pattern,
      caseSensitive: caseSensitive ?? this.caseSensitive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FilterView &&
        tag == other.tag &&
        enabled == other.enabled &&
        imageboard == other.imageboard &&
        name == other.name &&
        pattern == other.pattern;
  }

  @override
  int get hashCode =>
      tag.hashCode ^
      enabled.hashCode ^
      imageboard.hashCode ^
      name.hashCode ^
      pattern.hashCode;
}
