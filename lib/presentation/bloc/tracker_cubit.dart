import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treechan/domain/repositories/tracker_repository.dart';

import '../../domain/models/tracked_item.dart';

class TrackerCubit extends Cubit<TrackerState> {
  final TrackerRepository trackerRepository;
  TrackerCubit({required this.trackerRepository})
      : super(TrackerInitialState());

  late List<TrackedThread> threads;
  late List<TrackedBranch> branches;
  void loadTracker() async {
    try {
      threads = await trackerRepository.getTrackedThreads();
      branches = await trackerRepository.getTrackedBranches();
      emit(TrackerLoadedState(threads: threads, branches: branches));
    } catch (e) {
      emit(TrackerErrorState(e.toString()));
    }
  }

  void refreshAll() async {
    try {
      for (var item in [...threads, ...branches]) {
        await Future.delayed(const Duration(milliseconds: 1000));
        await refreshItem(item);
      }
    } on TimeoutException {
      loadTracker();
    } catch (e) {
      emit(TrackerErrorState(e.toString()));
    }
  }

  Future<void> refreshItem(TrackedItem item) async {
    try {
      emit(TrackerRefreshingState(
        threads: threads,
        branches: branches,
        refreshingItem: item,
      ));
      await trackerRepository.refreshItem(item);
      threads = await trackerRepository.getTrackedThreads();
      branches = await trackerRepository.getTrackedBranches();
      emit(TrackerLoadedState(threads: threads, branches: branches));
    } on TimeoutException {
      loadTracker();
    } catch (e) {
      emit(TrackerErrorState(e.toString()));
    }
  }

  void removeItem(TrackedItem item) async {
    try {
      await trackerRepository.removeItem(item);
      loadTracker();
    } catch (e) {
      emit(TrackerErrorState(e.toString()));
    }
  }

  void markAsRead(TrackedItem item) async {
    try {
      await trackerRepository.markAsRead(item);
      loadTracker();
    } catch (e) {
      emit(TrackerErrorState(e.toString()));
    }
  }
}

abstract class TrackerState {}

class TrackerInitialState extends TrackerState {}

class TrackerLoadedState extends TrackerState {
  final List<TrackedThread> threads;
  final List<TrackedBranch> branches;
  // final int? currentRefreshingItemId;
  // final String? currentRefreshingItemTag;
  TrackerLoadedState({
    required this.threads,
    required this.branches,
    // this.currentRefreshingItemId,
    // this.currentRefreshingItemTag
  });
}

class TrackerRefreshingState extends TrackerState {
  final List<TrackedThread> threads;
  final List<TrackedBranch> branches;
  final TrackedItem refreshingItem;
  TrackerRefreshingState({
    required this.threads,
    required this.branches,
    required this.refreshingItem,
  });
}

class TrackerErrorState extends TrackerState {
  final String message;

  TrackerErrorState(this.message);
}
