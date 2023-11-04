import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treechan/config/local_notifications.dart';
import 'package:treechan/data/local/tracker_database.dart';
import 'package:treechan/domain/models/refresh_notification.dart';
import 'package:treechan/domain/repositories/manager/branch_repository_manager.dart';
import 'package:treechan/domain/repositories/manager/thread_repository_manager.dart';
import 'package:treechan/exceptions.dart';
import 'package:treechan/utils/hash.dart';
import 'package:treechan/utils/string.dart';

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
  ///
  /// A [RefreshNotification] is passed to the stream on [updateThreadByTab] and
  /// [updateBranchByTab] calls. The stream is listened to in [_refreshThread] and
  /// [_refreshBranch] methods. When the notification is received the method
  /// returns.
  static final StreamController<RefreshNotification> refreshNotifier =
      StreamController<RefreshNotification>.broadcast();

  /// Stream that notifies when some tab is refreshed automatically.
  ///
  /// A [TrackedItem] is passed to the stream on [autoRefresh] calls.
  /// The stream is listened to in [TrackerCubit] and updates the UI accordingly.
  final StreamController<AutoRefreshNotification> autoRefreshNotifier =
      StreamController<AutoRefreshNotification>.broadcast();

  TrackerRepository._internal() {
    // start routine
    autoRefresh();
  }

  final TrackerDatabase db = TrackerDatabase();

  List<TrackedThread> threads = [];
  List<TrackedBranch> branches = [];

  void sendPushNotification() async {
    debugPrint('sendPushNotification() has been triggered.');
    final prefs = await SharedPreferences.getInstance();
    bool getAllUpdates = prefs.getBool('getAllUpdates') ?? false;

    final List<TrackedItem> nonZeroDifference = [...threads, ...branches]
        .where((element) => element.newPostsDiff != 0)
        .toList();
    if (nonZeroDifference.isEmpty) {
      debugPrint(
          'newPosts did not changed since last update. Nothing to notify about.');
    }

    for (var item in nonZeroDifference) {
      /// Don't send push notification if the tab is currently opened
      if (tabManager!.currentTab is IdMixin && tabManager!.isAppInForeground) {
        if (tabManager!.currentTab as IdMixin ==
            tabManager!.findTab(
                imageboard: item.imageboard,
                tag: item.tag,
                threadId: item is TrackedThread ? item.id : null,
                branchId: item is TrackedBranch ? item.branchId : null)) {
          return;
        }
      }
      String itemType = item is TrackedThread ? 'тред' : 'ветк';

      String body = '';
      String personalBody = '';
      final shortName = truncate(item.name, 30, ellipsis: true);
      body = '''В $itemTypeе $shortName новых постов: ${item.newPosts}, '''
          '''новых ответов: ${item.newReplies}.''';
      personalBody =
          'Вам ответили в $itemTypeе $shortName $item.newReplies раз(а).';

      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// We use hash of the tag and id to make sure that notifications for the same
      /// thread/branch are replaced instead of creating new ones
      final int notificationId = hashStringAndInt(item.tag, item.id);

      final notification = PushUpdateNotification(
        type: item is TrackedThread ? 'thread' : 'branch',
        imageboard: item.imageboard,
        boardTag: item.tag,
        id: item.id,
        threadId: item is TrackedBranch ? item.threadId : null,
        name: item.name,
      )..toJson();
      final payload = jsonEncode(notification);

      if (getAllUpdates && item.newReplies != 0) {
        await flutterLocalNotificationsPlugin.show(notificationId,
            'Вам ответили', personalBody, personalGroupNotificationDetails,
            payload: payload);
      } else if (getAllUpdates) {
        await flutterLocalNotificationsPlugin.show(
            notificationId,
            'Новые посты (${item.newPosts})',
            body,
            normalGroupNotificationDetails,
            payload: payload);
      }
    }
    // await groupNotifications();
  }

  Future<void> autoRefresh() async {
    while (true) {
      final prefs = await SharedPreferences.getInstance();
      final autoRefreshEnabled = prefs.getBool('trackerAutoRefresh') ?? true;
      final refreshInterval = prefs.getInt('refreshInterval') ?? 60;

      final commonList = [...threads, ...branches];
      if (autoRefreshEnabled) {
        debugPrint('Starting auto refresh...');
        for (int i = 0; i < commonList.length; i++) {
          /// Duration between each item refresh to avoid getting 429 error
          await Future.delayed(const Duration(milliseconds: 2000));
          autoRefreshNotifier.add(AutoRefreshNotification(
              item: commonList[i], isLast: i == commonList.length - 1));
        }
      }

      /// Duration between each auto refresh
      await Future.delayed(Duration(seconds: refreshInterval));
    }
  }

  /// Adds thread to the tracker database.
  Future<void> addThreadByTab(
      {required ThreadTab tab, required int posts}) async {
    await db.addThread(
      tab.imageboard,
      tab.tag,
      tab.id,
      tab.name ?? "Тред",
      posts,
    );
  }

  Future<void> removeThreadByTab(ThreadTab tab) async {
    await db.removeThread(tab.imageboard, tab.tag, tab.id);
  }

  Future<void> removeThread(
      Imageboard imageboard, String tag, int threadId) async {
    await db.removeThread(imageboard, tag, threadId);
  }

  /// Adds branch to the tracker database.
  Future<void> addBranchByTab(
      {required BranchTab tab, required int posts}) async {
    await db.addBranch(
      tab.imageboard,
      tab.tag,
      tab.threadId,
      tab.id,
      tab.name ?? "Ветка",
      posts,
    );
  }

  Future<void> removeBranchByTab(BranchTab tab) async {
    await db.removeBranch(tab.imageboard, tab.tag, tab.id);
  }

  Future<void> removeBranch(
      Imageboard imageboard, String tag, int branchId) async {
    await db.removeBranch(imageboard, tag, branchId);
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
        imageboard: tab.imageboard,
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
        imageboard: tab.imageboard,
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

  /// Call this from [ThreadBloc] when failed to refresh thread due
  /// to [NoConnectionException].
  void notifyFailedConnectionOnRefresh(IdMixin tab) {
    refreshNotifier
        .add(RefreshNotification.fromTab(tab, isDead: false, isError: true));
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

  Future<TrackedThread> getTrackedThread(
      Imageboard imageboard, String tag, int threadId) async {
    final map = await db.getTrackedThread(imageboard, tag, threadId);

    return TrackedThread(
      tag: map['tag'],
      threadId: map['threadId'],
      name: map['name'],
      imageboard: imageboardFromString(map['imageboard']),
      posts: map['posts'],
      newPosts: map['newPosts'],
      newPostsDiff: map['newPostsDiff'],
      newReplies: map['newReplies'],
      newRepliesDiff: map['newRepliesDiff'],
      isDead: map['isDead'] == 1,
      addTimestamp: map['addTimestamp'],
      refreshTimestamp: map['refreshTimestamp'],
    );
  }

  /// Gets all tracked threads from the database.
  /// This also updates [threads] field.
  Future<List<TrackedThread>> getTrackedThreads() async {
    final maps = await db.getTrackedThreads();

    final List<TrackedThread> threads = List.generate(maps.length, (i) {
      final map = maps[i];

      return TrackedThread(
        tag: map['tag'],
        threadId: map['threadId'],
        name: map['name'],
        imageboard: imageboardFromString(map['imageboard']),
        posts: map['posts'],
        newPosts: map['newPosts'],
        newPostsDiff: map['newPostsDiff'],
        newReplies: map['newReplies'],
        newRepliesDiff: map['newRepliesDiff'],
        isDead: map['isDead'] == 1,
        addTimestamp: map['addTimestamp'],
        refreshTimestamp: map['refreshTimestamp'],
      );
    });
    this.threads = threads;
    return threads;
  }

  Future<TrackedBranch> getTrackedBranch(
      Imageboard imageboard, String tag, int branchId) async {
    final map = await db.getTrackedBranch(imageboard, tag, branchId);

    return TrackedBranch(
      tag: map['tag'],
      branchId: map['branchId'],
      threadId: map['threadId'],
      name: map['name'],
      imageboard: imageboardFromString(map['imageboard']),
      posts: map['posts'],
      newPosts: map['newPosts'],
      newPostsDiff: map['newPostsDiff'],
      newReplies: map['newReplies'],
      newRepliesDiff: map['newRepliesDiff'],
      isDead: map['isDead'] == 1,
      addTimestamp: map['addTimestamp'],
      refreshTimestamp: map['refreshTimestamp'],
    );
  }

  /// Gets all tracked branches from the database.
  /// This also updates [branches] field.
  Future<List<TrackedBranch>> getTrackedBranches() async {
    final maps = await db.getTrackedBranches();

    final List<TrackedBranch> branches = List.generate(maps.length, (i) {
      final map = maps[i];

      return TrackedBranch(
        tag: map['tag'],
        branchId: map['branchId'],
        threadId: map['threadId'],
        name: map['name'],
        imageboard: imageboardFromString(map['imageboard']),
        posts: map['posts'],
        newPosts: map['newPosts'],
        newPostsDiff: map['newPostsDiff'],
        newReplies: map['newReplies'],
        newRepliesDiff: map['newRepliesDiff'],
        isDead: map['isDead'] == 1,
        addTimestamp: map['addTimestamp'],
        refreshTimestamp: map['refreshTimestamp'],
      );
    });
    this.branches = branches;
    return branches;
  }

  /// Gets all tracked items from the database.
  Future<List<TrackedItem>> getTrackedItems() async {
    List<TrackedThread> threads = await getTrackedThreads();
    List<TrackedBranch> branches = await getTrackedBranches();

    return [...threads, ...branches];
  }

  /// Adds refresh event to the tab bloc using [tabManager].
  ///
  /// Await this method to get notified when the thread is refreshed.
  Future<void> refreshItem(TrackedItem item) async {
    final IdMixin tab = tabManager!.findTab(
      imageboard: item.imageboard,
      tag: item.tag,
      threadId: item is TrackedThread ? item.id : null,
      branchId: item is TrackedBranch ? item.branchId : null,
    );

    if (tab.id == -1) {
      await _refreshClosedTab(item);
      return;
    }
    if (tab is ThreadTab) {
      await _refreshThread(tab);
      return;
    } else if (tab is BranchTab) {
      await _refreshBranch(tab);
      return;
    }
  }

  Future<void> _refreshThread(ThreadTab tab) async {
    Future.delayed(const Duration(milliseconds: 50), () {
      tabManager!.refreshTab(tab: tab, source: RefreshSource.tracker);
    });

    await refreshNotifier.stream.firstWhere((notification) {
      return notification.tag == tab.tag && notification.id == tab.id;
    }).timeout(const Duration(seconds: 10));
  }

  Future<void> _refreshBranch(BranchTab tab) async {
    Future.delayed(const Duration(milliseconds: 50),
        () => tabManager!.refreshTab(tab: tab, source: RefreshSource.tracker));

    await refreshNotifier.stream.firstWhere((notification) {
      return notification.tag == tab.tag && notification.id == tab.id;
    }).timeout(const Duration(seconds: 10));
  }

  Future<void> _refreshClosedTab(TrackedItem item) async {
    if (item is TrackedThread) {
      await _refreshClosedThread(item);
      return;
    } else if (item is TrackedBranch) {
      await _refreshClosedBranch(item);
    }
  }

  Future<void> _refreshClosedThread(TrackedThread thread) async {
    try {
      final ThreadRepository repo = ThreadRepositoryManager()
          .get(thread.imageboard, thread.tag, thread.threadId);
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
        imageboard: thread.imageboard,
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
        imageboard: thread.imageboard,
        prevTab: boardListTab,
      );
      markAsDead(mockTab);
    } on DioException catch (e) {
      debugPrint('Failed to refresh closed thread: ${e.toString()}');
      Future.delayed(
          const Duration(milliseconds: 10),
          () => refreshNotifier.add(RefreshNotification.fromItem(thread,
              isDead: false, isError: true)));
    } finally {
      await refreshNotifier.stream.firstWhere((notification) {
        return notification.tag == thread.tag &&
            notification.id == thread.threadId;
      });
    }
  }

  Future<void> _refreshClosedBranch(TrackedBranch branch) async {
    try {
      BranchRepository? branchRepo = BranchRepositoryManager()
          .get(branch.imageboard, branch.tag, branch.branchId);
      bool firstLoading = false;
      if (branchRepo == null) {
        final threadRepo = ThreadRepositoryManager()
            .get(branch.imageboard, branch.tag, branch.threadId);
        if (threadRepo.postsCount == 0) {
          await threadRepo.load();
        }
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
          name: '',
          imageboard: branch.imageboard,
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
          name: '',
          imageboard: branch.imageboard,
          prevTab: boardListTab);
      await markAsDead(mockTab);
    } on DioException catch (e) {
      debugPrint('Failed to refresh closed branch: (${e.toString()}');
      Future.delayed(
          const Duration(milliseconds: 10),
          () => refreshNotifier.add(RefreshNotification.fromItem(branch,
              isDead: false, isError: true)));
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
        imageboard: item.imageboard,
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
        name: '',
        imageboard: item.imageboard,
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
      await removeThread(item.imageboard, item.tag, item.threadId);

      /// If thread is not opened in any tab, remove it from the thread repository.
      if (tabManager!
              .findTab(
                  imageboard: item.imageboard,
                  tag: item.tag,
                  threadId: item.threadId)
              .id ==
          -1) {
        await ThreadRepositoryManager()
            .remove(item.imageboard, item.tag, item.threadId);
      }
    } else if (item is TrackedBranch) {
      await removeBranch(item.imageboard, item.tag, item.branchId);

      /// If branch is not opened in any tab, remove it from the branch repository.
      if (tabManager!
              .findTab(
                  imageboard: item.imageboard,
                  tag: item.tag,
                  branchId: item.branchId)
              .id ==
          -1) {
        await BranchRepositoryManager()
            .remove(item.imageboard, item.tag, item.branchId);
      }
    }
  }

  Future<void> clear() async {
    await db.clear();
  }

  // @pragma('vm:entry-point')
  // static Future<void> backgroundService(ServiceInstance service) async {
  //   // final prefs = await SharedPreferences.getInstance();

  //   DartPluginRegistrant.ensureInitialized();

  //   if (service is AndroidServiceInstance) {
  //     service.on('setAsForeground').listen((event) {
  //       service.setAsForegroundService();
  //     });

  //     service.on('setAsBackground').listen((event) {
  //       service.setAsBackgroundService();
  //     });
  //   }

  //   final timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
  //     if (service is AndroidServiceInstance) {
  //       debugPrint(timer.tick.toString());
  //     }
  //   });
  // }
}
