import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/config/local_notifications.dart';
import 'package:treechan/presentation/bloc/branch_bloc.dart';
import 'package:treechan/utils/constants/enums.dart';

import '../../presentation/bloc/board_bloc.dart';
import '../../presentation/bloc/board_list_bloc.dart';
import '../../presentation/bloc/thread_bloc.dart';

/// An initial tab for the drawer.
DrawerTab boardListTab =
    BoardListTab(name: "Доски", imageboard: Imageboard.dvach);

abstract class DrawerTab {
  String? name;
  Imageboard imageboard;
  DrawerTab({required this.name, required this.imageboard});
  getBloc(BuildContext context);

  factory DrawerTab.fromPush(PushUpdateNotification notification) {
    if (notification.type == 'thread') {
      return ThreadTab(
        tag: notification.boardTag,
        name: notification.name,
        imageboard: notification.imageboard,
        prevTab: boardListTab,
        id: notification.id,
      );
    } else if (notification.type == 'branch') {
      assert(notification.threadId != null,
          'threadId must not be null for branch');
      return BranchTab(
        tag: notification.boardTag,
        name: notification.name,
        imageboard: notification.imageboard,
        prevTab: boardListTab,
        id: notification.id,
        threadId: notification.threadId!,
      );
    } else {
      throw Exception('Unknown notification type');
    }
  }
}

mixin TagMixin {
  late final String tag;
  late DrawerTab prevTab;
}

/// Do not use this mixin without TagMixin.
mixin IdMixin<T> {
  late int id;
  late DrawerTab prevTab;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is T &&
        (this as dynamic).tag == (other as dynamic).tag &&
        (this as dynamic).id == (other as dynamic).id &&
        (this as dynamic).imageboard == (other as dynamic).imageboard;
  }

  @override
  int get hashCode =>
      (this as dynamic).tag.hashCode ^
      (this as dynamic).id.hashCode ^
      (this as dynamic).imageboard.hashCode;
}

class BoardListTab extends DrawerTab {
  BoardListTab({
    required super.name,
    required super.imageboard,
  });

  @override
  BoardListBloc getBloc(BuildContext context) {
    return BlocProvider.of<BoardListBloc>(context);
  }
}

class BoardTab extends DrawerTab with TagMixin {
  bool isCatalog;
  String? query;
  BoardTab(
      {this.isCatalog = false,
      this.query,
      super.name,
      required super.imageboard,
      required String tag,
      required DrawerTab prevTab}) {
    this.tag = tag;
    this.prevTab = prevTab;
  }

  @override
  BoardBloc getBloc(BuildContext context) {
    return BlocProvider.of<BoardBloc>(context);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BoardTab &&
        tag == other.tag &&
        imageboard == other.imageboard;
  }

  @override
  int get hashCode => tag.hashCode ^ imageboard.hashCode;
}

class ThreadTab extends DrawerTab with TagMixin, IdMixin<ThreadTab> {
  ThreadTab({
    required super.name,
    required super.imageboard,
    required String tag,
    required DrawerTab prevTab,
    required int id,
    this.archiveDate,
  }) {
    this.tag = tag;
    this.prevTab = prevTab;
    this.id = id;
  }

  String? archiveDate;

  @override
  ThreadBloc getBloc(BuildContext context) {
    return BlocProvider.of<ThreadBloc>(context);
  }

  HistoryTab toHistoryTab() {
    return HistoryTab(
      tag: tag,
      name: name,
      imageboard: imageboard,
      archiveDate: archiveDate,
      id: id,
      prevTab: prevTab,
      timestamp: DateTime.now(),
    );
  }
}

class BranchTab extends DrawerTab with TagMixin, IdMixin<BranchTab> {
  final int threadId;
  BranchTab({
    required super.name,
    required super.imageboard,
    required String tag,
    required DrawerTab prevTab,
    required int id,
    required this.threadId,
  }) {
    this.tag = tag;
    this.prevTab = prevTab;
    this.id = id;
  }

  @override
  BranchBloc getBloc(BuildContext context) {
    return BlocProvider.of<BranchBloc>(context);
  }

  ThreadTab? getParentThreadTab() {
    IdMixin tab = this;
    while (tab is! ThreadTab) {
      if (tab.prevTab is! IdMixin) {
        return null;
      }
      tab = tab.prevTab as IdMixin;
    }
    return tab;
  }
}

class HistoryTab extends ThreadTab {
  DateTime timestamp;
  HistoryTab({
    required super.tag,
    required super.name,
    required super.imageboard,
    required super.prevTab,
    required super.id,
    required this.timestamp,
    super.archiveDate,
  });

  DrawerTab toThreadTab() {
    return ThreadTab(
        tag: tag,
        name: name,
        imageboard: imageboard,
        archiveDate: archiveDate,
        id: id,
        prevTab: prevTab);
  }

  Map<String, dynamic> toMap() {
    return {
      'tag': tag,
      'name': name,
      'threadId': id,
      'imageboard': imageboard.name,
      'archiveDate': archiveDate,
      'timestamp': timestamp.toString(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HistoryTab &&
        other.tag == tag &&
        other.id == id &&
        other.timestamp == timestamp &&
        other.imageboard == imageboard;
  }

  @override
  int get hashCode {
    return tag.hashCode ^
        id.hashCode ^
        timestamp.hashCode ^
        imageboard.hashCode;
  }

  @override
  String toString() {
    return 'DrawerTab{tag: $tag, name: $name, id: $id}';
  }
}
