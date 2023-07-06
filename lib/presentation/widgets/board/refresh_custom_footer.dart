import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../bloc/board_bloc.dart';

/// A footer appears when user scrolls to the end of the board.
class RefreshCustomFooter extends StatelessWidget {
  const RefreshCustomFooter({
    super.key,
    required this.controller,
  });

  final RefreshController controller;

  @override
  Widget build(BuildContext context) {
    return CustomFooter(
      builder: (context, mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = Platform.isAndroid || Platform.isIOS
              ? const Center(child: CircularProgressIndicator())
              : InkWell(
                  child: const Text("Загрузить больше"),
                  onTap: () {
                    loadMore(context);
                  },
                );
        } else if (mode == LoadStatus.loading) {
          body = const CircularProgressIndicator();
        } else if (mode == LoadStatus.failed) {
          body = const Text("Ошибка");
        } else if (mode == LoadStatus.canLoading) {
          body = const Text("Отпустите для обновления");
        } else {
          body = InkWell(
            child: const Text("Все прочитано (нажмите для обновления)"),
            onTap: () {
              loadMore(context);
            },
          );
        }
        return SizedBox(
          height: 55,
          child: Center(child: body),
        );
      },
    );
  }

  void loadMore(BuildContext context) {
    controller.resetNoData();
    controller.loadComplete();
    BlocProvider.of<BoardBloc>(context).add(RefreshBoardEvent());
  }
}