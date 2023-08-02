/// An initial tab for the drawer.
DrawerTab boardListTab =
    BoardListTab(name: "Доски", tag: "boards", prevTab: null);

abstract class DrawerTab {
  String tag;
  String? name;
  final DrawerTab? prevTab;
  DrawerTab({required this.tag, this.name, required this.prevTab});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DrawerTab && tag == other.tag;
  }

  @override
  int get hashCode => tag.hashCode;
}

class BoardListTab extends DrawerTab {
  BoardListTab({
    required super.tag,
    super.name,
    required super.prevTab,
  });
}

class BoardTab extends DrawerTab {
  bool isCatalog;
  String? searchTag;
  BoardTab({
    required super.tag,
    super.name,
    required super.prevTab,
    this.isCatalog = false,
    this.searchTag,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BoardTab && tag == other.tag;
  }

  @override
  int get hashCode => tag.hashCode;
}

class ThreadTab extends DrawerTab {
  final int id;
  ThreadTab({
    required super.tag,
    super.name,
    required super.prevTab,
    required this.id,
  });

  HistoryTab toHistoryTab() {
    return HistoryTab(
      tag: tag,
      name: name,
      id: id,
      prevTab: prevTab,
      timestamp: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ThreadTab && tag == other.tag && id == other.id;
  }

  @override
  int get hashCode => tag.hashCode ^ id.hashCode;
}

class BranchTab extends DrawerTab {
  final int id;
  BranchTab({
    required super.tag,
    super.name,
    required super.prevTab,
    required this.id,
  });
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BranchTab && tag == other.tag && id == other.id;
  }

  @override
  int get hashCode => tag.hashCode ^ id.hashCode;
}

class HistoryTab extends DrawerTab {
  final int id;
  DateTime timestamp;
  HistoryTab({
    required super.tag,
    required super.name,
    required this.id,
    required super.prevTab,
    required this.timestamp,
  });

  DrawerTab toThreadTab() {
    return ThreadTab(tag: tag, name: name, id: id, prevTab: prevTab);
  }

  Map<String, dynamic> toMap() {
    return {
      'tag': tag,
      'name': name,
      'threadId': id,
      'timestamp': timestamp.toString(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HistoryTab &&
        other.tag == tag &&
        other.id == id &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return tag.hashCode ^ id.hashCode ^ timestamp.hashCode;
  }

  @override
  String toString() {
    return 'DrawerTab{tag: $tag, name: $name, id: $id}';
  }
}
