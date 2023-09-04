import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:treechan/presentation/provider/page_provider.dart';

import '../../domain/models/json/json.dart';
import '../../domain/models/tab.dart';
import '../../domain/repositories/thread_repository.dart';
import '../../domain/services/scroll_service.dart';

/// Base class for [ThreadBloc] and [BranchBloc].
///
/// Contains all the common fields.
/// Cast bloc to this class to access them.
mixin ThreadBase {
  late final ThreadRepository threadRepository;
  late final IdMixin tab;
  late final PageProvider provider;
  late Key key;

  late final ScrollController scrollController;
  late final ScrollService scrollService;

  /// Every time new post preview dialog opens the node from which it
  /// has been opened adds here.
  /// Used to check if some post is actually in the current visible tree.
  final List<TreeNode<Post>> dialogStack = [];

  Root get threadInfo;
}
