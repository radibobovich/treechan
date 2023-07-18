import '../../utils/constants/enums.dart';

/// An initial tab for the drawer.
DrawerTab boardListTab =
    DrawerTab(type: TabTypes.boardList, name: "Доски", tag: "boards");

class DrawerTab {
  TabTypes type;
  bool? isCatalog;
  String? searchTag; // to search something in catalog
  int? id;
  String? name;
  String tag;
  DrawerTab? prevTab;
  DrawerTab(
      {required this.type,
      this.id,
      required this.tag,
      this.name,
      this.prevTab,
      this.isCatalog,
      this.searchTag});

  HistoryTab toHistoryTab() {
    return HistoryTab(
        type: type, name: name, tag: tag, id: id, timestamp: DateTime.now());
  }

  DrawerTab getRidOfCatalog() {
    return DrawerTab(
        type: type, id: id, tag: tag, name: name, prevTab: prevTab);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DrawerTab &&
        type == other.type &&
        id == other.id &&
        tag == other.tag;
  }

  @override
  int get hashCode => type.hashCode ^ id.hashCode ^ tag.hashCode;
}

class HistoryTab extends DrawerTab {
  HistoryTab(
      {required super.type,
      super.id,
      required super.name,
      required super.tag,
      required this.timestamp});

  final DateTime timestamp;
  DrawerTab toDrawerTab() {
    return DrawerTab(
        type: type,
        id: id,
        name: name,
        tag: tag,
        prevTab: prevTab ?? boardListTab);
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString(),
      'name': name,
      'tag': tag,
      'threadId': id,
      'timestamp': DateTime.now().toString()
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HistoryTab &&
        other.type == type &&
        other.tag == tag &&
        other.id == id &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return type.hashCode ^ tag.hashCode ^ id.hashCode ^ timestamp.hashCode;
  }

  @override
  String toString() {
    return 'DrawerTab{type: ${type.toString()}, tag: $tag, id: $id, name: $name}';
  }
}
