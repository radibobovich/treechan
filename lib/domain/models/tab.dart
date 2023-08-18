import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/presentation/bloc/branch_bloc.dart';

import '../../presentation/bloc/board_bloc.dart';
import '../../presentation/bloc/board_list_bloc.dart';
import '../../presentation/bloc/thread_bloc.dart';

/// An initial tab for the drawer.
DrawerTab boardListTab = BoardListTab(name: "Доски");

abstract class DrawerTab {
  String? name;
  DrawerTab({required this.name});
  getBloc(BuildContext context);
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
        (this as dynamic).id == (other as dynamic).id;
  }

  @override
  int get hashCode =>
      (this as dynamic).tag.hashCode ^ (this as dynamic).id.hashCode;
}

class BoardListTab extends DrawerTab {
  BoardListTab({
    required super.name,
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
      required tag,
      required prevTab}) {
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

    return other is BoardTab && tag == other.tag;
  }

  @override
  int get hashCode => tag.hashCode;
}

class ThreadTab extends DrawerTab with TagMixin, IdMixin<ThreadTab> {
  ThreadTab({
    required super.name,
    required tag,
    required prevTab,
    required id,
  }) {
    this.tag = tag;
    this.prevTab = prevTab;
    this.id = id;
  }

  @override
  ThreadBloc getBloc(BuildContext context) {
    return BlocProvider.of<ThreadBloc>(context);
  }

  HistoryTab toHistoryTab() {
    return HistoryTab(
      tag: tag,
      name: name,
      id: id,
      prevTab: prevTab,
      timestamp: DateTime.now(),
    );
  }

  // @override
  // bool operator ==(Object other) {
  //   if (identical(this, other)) return true;

  //   return other is ThreadTab && tag == other.tag && id == other.id;
  // }

  // @override
  // int get hashCode => tag.hashCode ^ id.hashCode;
}

class BranchTab extends DrawerTab with TagMixin, IdMixin<BranchTab> {
  BranchTab({
    required super.name,
    required tag,
    required prevTab,
    required id,
  }) {
    this.tag = tag;
    this.prevTab = prevTab;
    this.id = id;
  }

  @override
  BranchBloc getBloc(BuildContext context) {
    return BlocProvider.of<BranchBloc>(context);
  }

  // @override
  // bool operator ==(Object other) {
  //   if (identical(this, other)) return true;

  //   return other is BranchTab && tag == other.tag && id == other.id;
  // }

  // @override
  // int get hashCode => tag.hashCode ^ id.hashCode;
}

class HistoryTab extends ThreadTab {
  DateTime timestamp;
  HistoryTab({
    required super.tag,
    required super.name,
    required super.prevTab,
    required super.id,
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
