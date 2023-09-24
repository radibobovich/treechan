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
