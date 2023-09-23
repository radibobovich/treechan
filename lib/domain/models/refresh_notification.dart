import 'package:treechan/domain/models/tracked_item.dart';

import 'tab.dart';

class RefreshNotification {
  final String tag;
  final int id;
  final bool isDead;
  final bool isError;
  RefreshNotification(
      {required this.tag,
      required this.id,
      required this.isDead,
      this.isError = false});
  RefreshNotification.fromTab(IdMixin tab,
      {required this.isDead, this.isError = false})
      : tag = (tab as TagMixin).tag,
        id = tab.id;
  RefreshNotification.fromItem(TrackedItem item,
      {required this.isDead, this.isError = false})
      : tag = item.tag,
        id = item.id;
}

class AutoRefreshNotification {
  final TrackedItem item;
  final bool isLast;
  AutoRefreshNotification({
    required this.item,
    this.isLast = false,
  });
}
