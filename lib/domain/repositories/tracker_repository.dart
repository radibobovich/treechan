import 'dart:async';

import 'package:treechan/domain/models/refresh_notification.dart';
import 'package:treechan/domain/repositories/manager/branch_repository_manager.dart';
import 'package:treechan/domain/repositories/manager/thread_repository_manager.dart';
import 'package:treechan/exceptions.dart';

import '../../data/tracker_database.dart';
import '../../presentation/provider/tab_manager.dart';
import '../../utils/constants/enums.dart';
import '../models/tab.dart';
import '../models/tracked_item.dart';
import 'branch_repository.dart';
import 'thread_repository.dart';

class TrackerRepository {
  static final TrackerRepository _instance = TrackerRepository._internal();

  factory TrackerRepository({TabManager? initTabManager}) {
    if (initTabManager != null && tabManager == null) {
      tabManager = initTabManager;
    }
    return _instance;
  }
  static TabManager? tabManager;

  /// Stream that notifies when some tab is refreshed.
  /// A [RefreshNotification] is passed to the stream on [updateThreadByTab] and
  /// [updateBranchByTab] calls. The stream is listened to in [_refreshThread] and
  /// [_refreshBranch] methods. When the notification is received the method
  /// returns.
  static final StreamController<RefreshNotification> refreshNotifier =
      StreamController<RefreshNotification>.broadcast();

  TrackerRepository._internal();

  final TrackerDatabase db = TrackerDatabase();

  /// Adds thread to the tracker database.
  Future<void> addThreadByTab(
      {required ThreadTab tab, required int posts}) async {
    await db.addThread(
      tab.tag,
      tab.id,
      tab.name ?? "Тред",
      posts,
    );
  }

  Future<void> removeThreadByTab(ThreadTab tab) async {
    await db.removeThread(tab.tag, tab.id);
  }

  Future<void> removeThread(String tag, int threadId) async {
    await db.removeThread(tag, threadId);
  }

  /// Adds branch to the tracker database.
  Future<void> addBranchByTab(
      {required BranchTab tab,
      required int posts,
      required int threadId}) async {
    await db.addBranch(
      tab.tag,
      threadId,
      tab.id,
      tab.name ?? "Ветка",
      posts,
    );
  }

  Future<void> removeBranchByTab(BranchTab tab) async {
    await db.removeBranch(tab.tag, tab.id);
  }

  Future<void> removeBranch(String tag, int branchId) async {
    await db.removeBranch(tag, branchId);
  }

  /// Updates thread in the tracker database with new [posts], [newPosts]
  /// count and [isDead] status.
  Future<void> updateThreadByTab(
      {required ThreadTab tab,
      required int? posts,
      required int newPosts,
      required int newReplies,
      bool forceNewPosts = false,
      bool forceNewReplies = false,
      bool isDead = false}) async {
    await db.updateThread(
        tag: tab.tag,
        threadId: tab.id,
        posts: posts,
        newPosts: newPosts,
        newReplies: newReplies,
        forceNewPosts: forceNewPosts,
        forceNewReplies: forceNewReplies,
        isDead: isDead);
    refreshNotifier.add(RefreshNotification.fromTab(tab, isDead: isDead));
  }

  /// Updates branch in the tracker database with new [posts], [newPosts]
  /// count and [isDead] status.
  Future<void> updateBranchByTab(
      {required BranchTab tab,
      required int? posts,
      required int newPosts,
      required int newReplies,
      bool forceNewPosts = false,
      bool forceNewReplies = false,
      bool isDead = false}) async {
    await db.updateBranch(
        tag: tab.tag,
        branchId: tab.id,
        posts: posts,
        newPosts: newPosts,
        newReplies: newReplies,
        forceNewPosts: forceNewPosts,
        forceNewReplies: forceNewReplies,
        isDead: isDead);
    refreshNotifier.add(RefreshNotification.fromTab(tab, isDead: isDead));
  }

  /// Marks thread or branch as dead. Called when thread is not found on refresh.
  Future<void> markAsDead(IdMixin tab) async {
    if (tab is ThreadTab) {
      await updateThreadByTab(
        tab: tab,
        posts: null,
        newPosts: 0,
        newReplies: 0,
        isDead: true,
      );
    } else {
      await updateBranchByTab(
        tab: tab as BranchTab,
        posts: null,
        newPosts: 0,
        newReplies: 0,
        isDead: true,
      );
    }
  }

  /// Gets all tracked threads from the database.
  Future<List<TrackedThread>> getTrackedThreads() async {
    final maps = await db.getTrackedThreads();

    final List<TrackedThread> threads = List.generate(maps.length, (i) {
      final map = maps[i];

      return TrackedThread(
        tag: map['tag'],
        threadId: map['threadId'],
        name: map['name'],
        posts: map['posts'],
        newPosts: map['newPosts'],
        newReplies: map['newReplies'],
        isDead: map['isDead'] == 1,
        addTimestamp: map['addTimestamp'],
        refreshTimestamp: map['refreshTimestamp'],
      );
    });

    return threads;
  }

  /// Gets all tracked branches from the database.
  Future<List<TrackedBranch>> getTrackedBranches() async {
    final maps = await db.getTrackedBranches();

    final List<TrackedBranch> branches = List.generate(maps.length, (i) {
      final map = maps[i];

      return TrackedBranch(
        tag: map['tag'],
        branchId: map['branchId'],
        threadId: map['threadId'],
        name: map['name'],
        posts: map['posts'],
        newPosts: map['newPosts'],
        newReplies: map['newReplies'],
        isDead: map['isDead'] == 1,
        addTimestamp: map['addTimestamp'],
        refreshTimestamp: map['refreshTimestamp'],
      );
    });

    return branches;
  }

  /// Gets all tracked items from the database.
  Future<List<TrackedItem>> getTrackedItems() async {
    List<TrackedThread> threads = await getTrackedThreads();
    List<TrackedBranch> branches = await getTrackedBranches();

    return [...threads, ...branches];
  }

  /// Refreshes all tracked items and sends an event to a stream
  /// which is listened to in [TrackerCubit]. The event is used to update
  /// the UI every time an item is refreshed.
  // Stream<int> refreshAllItems() async* {
  //   final List<TrackedItem> items = await getTrackedItems();
  //   for (int i = 0; i< items.length; i++) {
  //     await Future.delayed(const Duration(seconds: 2));
  //     await refreshItem(items[i]);
  //     yield i;
  //   }
  // }

  /// Adds refresh event to the tab bloc using [tabManager].
  ///
  /// Await this method to get notified when the thread is refreshed.
  Future<void> refreshItem(TrackedItem item) async {
    final IdMixin tab = tabManager!.findTab(
      tag: item.tag,
      threadId: item.id,
      branchId: item is TrackedBranch ? item.branchId : null,
    );

    if (tab.id == -1) {
      await _refreshClosedTab(item);
      return;
    }
    if (tab is ThreadTab) {
      await _refreshThread(tab);
    } else if (tab is BranchTab) {
      await _refreshBranch(tab);
    }
  }

  Future<void> _refreshThread(ThreadTab tab) async {
    tabManager!.refreshTab(tab: tab, source: RefreshSource.tracker);

    await refreshNotifier.stream.firstWhere((notification) {
      return notification.tag == tab.tag && notification.id == tab.id;
    }).timeout(const Duration(seconds: 10));
  }

  Future<void> _refreshBranch(BranchTab tab) async {
    tabManager!.refreshTab(tab: tab, source: RefreshSource.tracker);

    await refreshNotifier.stream.firstWhere((notification) {
      return notification.tag == tab.tag && notification.id == tab.id;
    }).timeout(const Duration(seconds: 10));
  }

  Future<void> _refreshClosedTab(TrackedItem item) async {
    if (item is TrackedThread) {
      await _refreshClosedThread(item);
    } else if (item is TrackedBranch) {
      await _refreshClosedBranch(item);
    }
  }

  Future<void> _refreshClosedThread(TrackedThread thread) async {
    try {
      final ThreadRepository repo =
          ThreadRepositoryManager().get(thread.tag, thread.threadId);
      bool firstLoading = false;
      if (repo.postsCount == 0) {
        await repo.load();
        firstLoading = true;
      } else {
        await repo.refresh();
      }
      final mockTab = ThreadTab(
        tag: thread.tag,
        id: thread.threadId,
        name: null,
        prevTab: boardListTab,
      );
      updateThreadByTab(
          tab: mockTab,
          posts: repo.postsCount != 0 ? repo.postsCount : null,
          // newPosts: repo.newPostsCount,
          newPosts: repo.postsCount - thread.posts,
          forceNewPosts: firstLoading,
          newReplies: repo.newReplies);
    } on ThreadNotFoundException {
      final mockTab = ThreadTab(
        tag: thread.tag,
        id: thread.threadId,
        name: null,
        prevTab: boardListTab,
      );
      markAsDead(mockTab);
    } finally {
      await refreshNotifier.stream.firstWhere((notification) {
        return notification.tag == thread.tag &&
            notification.id == thread.threadId;
      });
    }
  }

  Future<void> _refreshClosedBranch(TrackedBranch branch) async {
    try {
      BranchRepository? branchRepo =
          BranchRepositoryManager().get(branch.tag, branch.branchId);
      bool firstLoading = false;
      if (branchRepo == null) {
        final threadRepo =
            ThreadRepositoryManager().get(branch.tag, branch.threadId);
        if (threadRepo.postsCount == 0) await threadRepo.load();

        branchRepo =
            BranchRepositoryManager().create(threadRepo, branch.branchId);
      }
      if (branchRepo.postsCount == 0) {
        await branchRepo.load();
        firstLoading = true;
      } else {
        await branchRepo.refresh(RefreshSource.tracker);
      }
      final mockTab = BranchTab(
          id: branch.branchId,
          threadId: branch.threadId,
          tag: branch.tag,
          name: null,
          prevTab: boardListTab);
      updateBranchByTab(
          tab: mockTab,
          posts: branchRepo.postsCount != 0 ? branchRepo.postsCount : null,
          // newPosts: branchRepo.newPostsCount,
          newPosts: branchRepo.postsCount - branch.posts,
          forceNewPosts: firstLoading,
          newReplies: branchRepo.newReplies);
    } on ThreadNotFoundException {
      final mockTab = BranchTab(
          id: branch.branchId,
          threadId: branch.threadId,
          tag: branch.tag,
          name: null,
          prevTab: boardListTab);
      await markAsDead(mockTab);
    } finally {
      await refreshNotifier.stream.firstWhere((notification) {
        return notification.tag == branch.tag &&
            notification.id == branch.branchId;
      });
    }
  }

  Future<void> markAsRead(TrackedItem item) async {
    if (item is TrackedThread) {
      final mockTab = ThreadTab(
        tag: item.tag,
        id: item.threadId,
        name: null,
        prevTab: boardListTab,
      );
      await updateThreadByTab(
        tab: mockTab,
        posts: null,
        newPosts: 0,
        forceNewPosts: true,
        newReplies: 0,
        forceNewReplies: true,
      );
    } else if (item is TrackedBranch) {
      final mockTab = BranchTab(
        tag: item.tag,
        id: item.branchId,
        threadId: item.threadId,
        name: null,
        prevTab: boardListTab,
      );
      await updateBranchByTab(
        tab: mockTab,
        posts: null,
        newPosts: 0,
        forceNewPosts: true,
        newReplies: 0,
        forceNewReplies: true,
      );
    }
  }

  Future<bool> isTracked(IdMixin tab) async {
    return db.isTracked(tab);
  }

  Future<void> removeItem(TrackedItem item) async {
    if (item is TrackedThread) {
      await removeThread(item.tag, item.threadId);

      /// If thread is not opened in any tab, remove it from the thread repository.
      if (tabManager!.findTab(tag: item.tag, threadId: item.threadId).id ==
          -1) {
        await ThreadRepositoryManager().remove(item.tag, item.threadId);
      }
    } else if (item is TrackedBranch) {
      await removeBranch(item.tag, item.branchId);

      /// If branch is not opened in any tab, remove it from the branch repository.
      if (tabManager!.findTab(tag: item.tag, branchId: item.branchId).id ==
          -1) {
        await BranchRepositoryManager().remove(item.tag, item.branchId);
      }
    }
  }

  Future<void> clear() async {
    await db.clear();
  }
}
