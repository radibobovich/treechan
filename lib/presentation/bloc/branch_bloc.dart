import 'dart:ui';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/domain/models/json/json.dart';
import 'package:treechan/presentation/bloc/thread_bloc.dart';
import 'package:treechan/utils/constants/enums.dart';

import '../../domain/models/tab.dart';
import '../../domain/models/tree.dart';
import '../../domain/services/branch_service.dart';
import '../../domain/services/scroll_service.dart';
import '../../domain/services/thread_service.dart';

class BranchBloc extends Bloc<BranchEvent, BranchState> {
  final ThreadBloc threadBloc;
  final int postId;
  final DrawerTab prevTab;

  late TreeNode<Post> branch;
  late ThreadService threadService;
  late BranchService branchService;

  final ScrollController scrollController = ScrollController();
  late final ScrollService scrollService;
  Key key;
  BranchBloc(
      {required this.threadBloc,
      required this.postId,
      required this.prevTab,
      required this.key})
      : super(BranchInitialState()) {
    threadService = threadBloc.threadService;
    branchService = BranchService(threadService: threadService, postId: postId);
    scrollService = ScrollService(scrollController,
        (window.physicalSize / window.devicePixelRatio).width);
    on<LoadBranchEvent>(
      (event, emit) async {
        try {
          branch = await branchService.getBranch();
          emit(BranchLoadedState(
              branch: branch,
              threadInfo: threadBloc.threadService.getThreadInfo));
        } on Exception catch (e) {
          emit(BranchErrorState(message: e.toString(), exception: e));
        }
      },
    );
    on<RefreshBranchEvent>(
      (event, emit) async {
        int oldPostCount = 0;
        if (event.source == RefreshSource.branch) {
          oldPostCount = Tree.countNodes(branch);

          if (oldPostCount > 0 && scrollController.offset != 0) {
            scrollService.saveCurrentScrollInfo();
          }
        }
        await branchService.refresh(event.source, lastIndex: event.lastIndex);
        add(LoadBranchEvent());
        if (event.source == RefreshSource.branch) {
          if (!threadBloc.isClosed) threadBloc.add(LoadThreadEvent());

          int newPostCount = Tree.countNodes(branch);

          await Future.delayed(const Duration(milliseconds: 10));

          if (oldPostCount > 0 &&
              newPostCount > oldPostCount &&
              scrollController.offset != 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              scrollService.updateScrollPosition();
            });
          }
        }
      },
    );
  }
}

abstract class BranchEvent {}

class LoadBranchEvent extends BranchEvent {}

class RefreshBranchEvent extends BranchEvent {
  RefreshSource source;
  int? lastIndex;
  RefreshBranchEvent(this.source, {this.lastIndex}) {
    if (source == RefreshSource.thread) assert(lastIndex != null);
  }
}

abstract class BranchState {}

class BranchInitialState extends BranchState {}

class BranchLoadedState extends BranchState {
  TreeNode<Post> branch;
  Root threadInfo;
  BranchLoadedState({required this.branch, required this.threadInfo});
}

class BranchErrorState extends BranchState {
  final String message;
  final Exception? exception;
  BranchErrorState({required this.message, this.exception});
}
