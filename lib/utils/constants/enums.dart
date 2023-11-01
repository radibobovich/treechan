// Actions in the favorite list of boards in BoardListScreen
enum FavoriteListAction { add, remove, toggleReorder, saveAll }

// Sort by in the catalog of threads in BoardScreen
enum SortBy { page, bump, time }

enum RefreshSource { thread, branch, tracker }

enum System {
  android,
  ios,
  fuchsia,
  haiku,
  linux,
  macos,
  windows7,
  windowsVista,
  windows8,
  windows10,
  unknown
}

enum Browser {
  chromium,
  firefox,
  opera,
  safari,
  mobileSafari,
  yandex,
  unknown,
  palemoon,
  internetExplorer
}

enum Imageboard { dvach, dvachArchive, unknown }

Map<Imageboard, Imageboard> archivesMap = {
  Imageboard.dvach: Imageboard.dvachArchive
};

Imageboard imageboardFromString(String str) {
  for (Imageboard value in Imageboard.values) {
    if (value.name == str) return value;
  }
  throw Exception('Unknown imageboard');
}

/// Returns imageboards which are not archives.
List<Imageboard> getOriginalImageboards({bool withUnknown = false}) {
  return Imageboard.values.toList()
    ..removeWhere((element) =>
        archivesMap.containsValue(element) ||
        (!withUnknown && element == Imageboard.unknown));
}

enum FiltersDisplayMode { all, board }

enum BoardView { treechan, classic }

BoardView boardViewFromString(String str) {
  for (BoardView value in BoardView.values) {
    if (value.name == str) return value;
  }
  throw Exception('Unknown board view');
}
