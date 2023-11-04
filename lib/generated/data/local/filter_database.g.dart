// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../data/local/filter_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorFilterDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$FilterDatabaseBuilder databaseBuilder(String name) =>
      _$FilterDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$FilterDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$FilterDatabaseBuilder(null);
}

class _$FilterDatabaseBuilder {
  _$FilterDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$FilterDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$FilterDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<FilterDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$FilterDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$FilterDatabase extends FilterDatabase {
  _$FilterDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  FilterDao? _filterDaoInstance;

  BoardDao? _boardDaoInstance;

  FilterBoardRelationshipDao? _relationshipDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Filter` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `enabled` INTEGER NOT NULL, `imageboard` TEXT NOT NULL, `name` TEXT NOT NULL, `pattern` TEXT NOT NULL, `caseSensitive` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Board` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `tag` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `FilterBoardRelationship` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `filter_reference` INTEGER NOT NULL, `board_reference` INTEGER NOT NULL, FOREIGN KEY (`filter_reference`) REFERENCES `Filter` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, FOREIGN KEY (`board_reference`) REFERENCES `Board` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_Board_tag` ON `Board` (`tag`)');
        await database.execute(
            'CREATE VIEW IF NOT EXISTS `FilterView` AS SELECT \"Filter\".*, Board.tag\nFROM \"Filter\"\nLEFT JOIN FilterBoardRelationship ON \"Filter\".id = FilterBoardRelationship.filter_reference\nLEFT JOIN Board ON FilterBoardRelationship.board_reference = Board.id\nORDER BY \"Filter\".id ASC\n');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  FilterDao get filterDao {
    return _filterDaoInstance ??= _$FilterDao(database, changeListener);
  }

  @override
  BoardDao get boardDao {
    return _boardDaoInstance ??= _$BoardDao(database, changeListener);
  }

  @override
  FilterBoardRelationshipDao get relationshipDao {
    return _relationshipDaoInstance ??=
        _$FilterBoardRelationshipDao(database, changeListener);
  }
}

class _$FilterDao extends FilterDao {
  _$FilterDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _filterInsertionAdapter = InsertionAdapter(
            database,
            'Filter',
            (Filter item) => <String, Object?>{
                  'id': item.id,
                  'enabled': item.enabled ? 1 : 0,
                  'imageboard': item.imageboard,
                  'name': item.name,
                  'pattern': item.pattern,
                  'caseSensitive': item.caseSensitive ? 1 : 0
                }),
        _filterUpdateAdapter = UpdateAdapter(
            database,
            'Filter',
            ['id'],
            (Filter item) => <String, Object?>{
                  'id': item.id,
                  'enabled': item.enabled ? 1 : 0,
                  'imageboard': item.imageboard,
                  'name': item.name,
                  'pattern': item.pattern,
                  'caseSensitive': item.caseSensitive ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Filter> _filterInsertionAdapter;

  final UpdateAdapter<Filter> _filterUpdateAdapter;

  @override
  Future<List<FilterView>> getFilters() async {
    return _queryAdapter.queryList('SELECT * FROM FilterView',
        mapper: (Map<String, Object?> row) => FilterView(
            tag: row['tag'] as String,
            id: row['id'] as int?,
            enabled: (row['enabled'] as int) != 0,
            imageboard: row['imageboard'] as String,
            name: row['name'] as String,
            pattern: row['pattern'] as String,
            caseSensitive: (row['caseSensitive'] as int) != 0));
  }

  @override
  Future<Filter?> getFilterById(int id) async {
    return _queryAdapter.query('SELECT * FROM \"Filter\" WHERE id = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => Filter(
            id: row['id'] as int?,
            enabled: (row['enabled'] as int) != 0,
            imageboard: row['imageboard'] as String,
            name: row['name'] as String,
            pattern: row['pattern'] as String,
            caseSensitive: (row['caseSensitive'] as int) != 0),
        arguments: [id]);
  }

  @override
  Future<void> toggleAllFilters(bool enabled) async {
    await _queryAdapter.queryNoReturn('UPDATE \"Filter\" SET enabled = ?1',
        arguments: [enabled ? 1 : 0]);
  }

  @override
  Future<void> toggleAllFiltersForBoard(
    bool enabled,
    String imageboard,
    int boardId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE \"Filter\" SET enabled = ?1   WHERE imageboard = ?2 AND id IN    (SELECT filter_reference FROM FilterBoardRelationship     WHERE board_reference = ?3)',
        arguments: [enabled ? 1 : 0, imageboard, boardId]);
  }

  @override
  Future<void> deleteFilterById(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM \"Filter\" WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> clear() async {
    await _queryAdapter.queryNoReturn('DELETE FROM \"Filter\"');
  }

  @override
  Future<int> insertFilter(Filter filter) {
    return _filterInsertionAdapter.insertAndReturnId(
        filter, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateFilter(Filter filter) async {
    await _filterUpdateAdapter.update(filter, OnConflictStrategy.abort);
  }
}

class _$BoardDao extends BoardDao {
  _$BoardDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _boardInsertionAdapter = InsertionAdapter(database, 'Board',
            (Board item) => <String, Object?>{'id': item.id, 'tag': item.tag});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Board> _boardInsertionAdapter;

  @override
  Future<Board?> findBoardBytag(String tag) async {
    return _queryAdapter.query('SELECT * FROM Board WHERE tag = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) =>
            Board(id: row['id'] as int?, tag: row['tag'] as String),
        arguments: [tag]);
  }

  @override
  Future<void> clear() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Board');
  }

  @override
  Future<int> insertBoard(Board board) {
    return _boardInsertionAdapter.insertAndReturnId(
        board, OnConflictStrategy.ignore);
  }
}

class _$FilterBoardRelationshipDao extends FilterBoardRelationshipDao {
  _$FilterBoardRelationshipDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _filterBoardRelationshipInsertionAdapter = InsertionAdapter(
            database,
            'FilterBoardRelationship',
            (FilterBoardRelationship item) => <String, Object?>{
                  'id': item.id,
                  'filter_reference': item.filterReference,
                  'board_reference': item.boardReference
                }),
        _filterBoardRelationshipDeletionAdapter = DeletionAdapter(
            database,
            'FilterBoardRelationship',
            ['id'],
            (FilterBoardRelationship item) => <String, Object?>{
                  'id': item.id,
                  'filter_reference': item.filterReference,
                  'board_reference': item.boardReference
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<FilterBoardRelationship>
      _filterBoardRelationshipInsertionAdapter;

  final DeletionAdapter<FilterBoardRelationship>
      _filterBoardRelationshipDeletionAdapter;

  @override
  Future<List<FilterBoardRelationship>> getRelationships() async {
    return _queryAdapter.queryList('SELECT * from FilterBoardRelationship',
        mapper: (Map<String, Object?> row) => FilterBoardRelationship(
            id: row['id'] as int?,
            filterReference: row['filter_reference'] as int,
            boardReference: row['board_reference'] as int));
  }

  @override
  Future<List<FilterBoardRelationship>> getRelationshipsByFilterId(
      int filterId) async {
    return _queryAdapter.queryList(
        'SELECT * from FilterBoardRelationship   WHERE filter_reference = ?1',
        mapper: (Map<String, Object?> row) => FilterBoardRelationship(
            id: row['id'] as int?,
            filterReference: row['filter_reference'] as int,
            boardReference: row['board_reference'] as int),
        arguments: [filterId]);
  }

  @override
  Future<void> deleteRelationshipByForeignKeys(
    int filterId,
    int boardId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM FilterBoardRelationship  WHERE filter_reference = ?1 AND board_reference = ?2',
        arguments: [filterId, boardId]);
  }

  @override
  Future<List<FilterBoardRelationship>> getRelationshipsByBoardId(
    int boardId,
    String imageboard,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM FilterBoardRelationship WHERE board_reference = ?1 AND (SELECT imageboard    FROM \"Filter\"    WHERE \"Filter\".id = FilterBoardRelationship.filter_reference)  = ?2',
        mapper: (Map<String, Object?> row) => FilterBoardRelationship(id: row['id'] as int?, filterReference: row['filter_reference'] as int, boardReference: row['board_reference'] as int),
        arguments: [boardId, imageboard]);
  }

  @override
  Future<void> clear() async {
    await _queryAdapter.queryNoReturn('DELETE FROM FilterBoardRelationship');
  }

  @override
  Future<int> insertRelationship(FilterBoardRelationship relationship) {
    return _filterBoardRelationshipInsertionAdapter.insertAndReturnId(
        relationship, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteRelationship(FilterBoardRelationship relationship) async {
    await _filterBoardRelationshipDeletionAdapter.delete(relationship);
  }
}
