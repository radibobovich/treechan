import 'dart:async';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../models/json/post_json.dart';
import '../../presentation/widgets/thread/post_widget.dart';
import '../models/tree.dart';

/// A service generally to scroll to a post after thread refresh.
class ScrollService {
  List<dynamic> visiblePosts = List.empty(growable: true);
  // TODO: dont keep partially visible posts, determine is post visible using visibleBounds.center
  List<dynamic> partiallyVisiblePosts = List.empty(growable: true);

  final ScrollController _scrollController;
  final double _screenHeight;
  ScrollService(this._scrollController, this._screenHeight);

  PostWidget? _firstVisiblePost;
  double? _initialOffset;

  /// Saves current first visible post and its offset before thread refresh.
  void saveCurrentScrollInfo() async {
    _firstVisiblePost = getFirstVisiblePost();
    _initialOffset = _getOffset(_firstVisiblePost!.key!);
  }

  /// Sorts visible posts by its position and returns the topmost.
  PostWidget getFirstVisiblePost() {
    Map<PostWidget, double> posts = {};
    for (PostWidget post in visiblePosts) {
      double? y = _getOffset(post.key!);
      if (y != null) {
        posts[post] = y;
      }
    }
    Map<PostWidget, double> sortedByOffset = Map.fromEntries(
        posts.entries.toList()..sort((e1, e2) => e1.value.compareTo(e2.value)));
    // for debugging
    List<String> visibleIds = [];
    for (PostWidget post in visiblePosts) {
      visibleIds.add(post.node.data.id.toString());
    }
    if (sortedByOffset.isEmpty) {
      return partiallyVisiblePosts.first;
    }
    return sortedByOffset.keys.first;
  }

  /// Gets vertical absolute offset of the widget.
  double? _getOffset(Key key) {
    RenderObject? obj;
    RenderBox? box;
    obj = (key as GlobalKey).currentContext?.findRenderObject(); // null
    box = obj != null ? obj as RenderBox : null;
    Offset? position = box?.localToGlobal(Offset.zero);
    return position?.dy;
  }

  /// Scrolls down until the post that was at the top of the screen
  /// returns to its place. Called after thread refresh.
  Future<void> updateScrollPosition() async {
    if (_firstVisiblePost == null) {
      return;
    }
    double? currentOffset;
    Completer<void> completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentOffset = _getOffset(_firstVisiblePost!.key!);
      completer.complete();
    });
    await completer.future;
    if (currentOffset == _initialOffset) {
      return;
    }
    Timer.periodic(const Duration(milliseconds: 60), (timer) {
      // if (currentOffset != null &&
      //     (currentOffset! < _initialOffset! + 20 ||
      //         currentOffset! > _initialOffset! - 20)) {
      //   timer.cancel();
      // }
      if (currentOffset == null) {
        // https://stackoverflow.com/questions/49553402/how-to-determine-screen-height-and-width
        _scrollController.animateTo(_scrollController.offset + _screenHeight,
            duration: const Duration(milliseconds: 20), curve: Curves.easeOut);
      } else {
        // _scrollController.animateTo(
        //     _scrollController.offset + (currentOffset! - _initialOffset!),
        //     duration: const Duration(milliseconds: 100),
        //     curve: Curves.easeOut);
        timer.cancel();
        Scrollable.ensureVisible(
            (_firstVisiblePost!.key! as GlobalKey).currentContext!,
            duration: const Duration(milliseconds: 30),
            curve: Curves.easeOut);
        timer.cancel();
      }
      currentOffset = _getOffset(_firstVisiblePost!.key!);
    });

    return;
  }

  void checkVisibility(
      {required dynamic widget,
      required VisibilityInfo visibilityInfo,
      required Post post}) {
    if (true) {
      if (visibilityInfo.visibleFraction == 1) {
        // debugPrint("Post ${post.id} is visible, key is $widget.key");
        if (!visiblePosts.contains(widget)) {
          visiblePosts.add(widget);
        }
      }
      if (visibilityInfo.visibleFraction < 1 && visiblePosts.contains(widget)) {
        // debugPrint("Post ${post.id} is invisible");
        visiblePosts.remove(widget);
      }
      if (visibilityInfo.visibleFraction < 1 &&
          !visiblePosts.contains(widget) &&
          !partiallyVisiblePosts.contains(widget)) {
        partiallyVisiblePosts.add(widget);
      }
      if ((visibilityInfo.visibleFraction == 1 ||
              visibilityInfo.visibleFraction == 0) &&
          partiallyVisiblePosts.contains(widget)) {
        partiallyVisiblePosts.remove(widget);
      }
    }
  }

  Future<bool> scrollToNodeInDirection(GlobalKey key,
      {required AxisDirection direction}) async {
    Completer<bool> scrollCompleter = Completer();
    double? currentOffset;

    double offsetModifier = (direction == AxisDirection.up)
        ? -_screenHeight / 2
        : _screenHeight / 2;

    Completer<void> offsetCompleter = Completer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentOffset = _getOffset(key);
      offsetCompleter.complete();
    });
    await offsetCompleter.future;

    Timer.periodic(const Duration(milliseconds: 60), (timer) async {
      if (currentOffset == null) {
        if (_scrollController.offset == 0 ||
            _scrollController.offset ==
                _scrollController.position.maxScrollExtent) {
          timer.cancel();
          scrollCompleter.complete(false);
          return;
        }
        _scrollController.animateTo(_scrollController.offset + offsetModifier,
            duration: const Duration(milliseconds: 20), curve: Curves.easeOut);
      } else {
        timer.cancel();
        Scrollable.ensureVisible(key.currentContext!,
            duration: const Duration(milliseconds: 30), curve: Curves.easeOut);
        scrollCompleter.complete(true);
        return;
      }
      Completer<void> offsetCompleter = Completer();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        currentOffset = _getOffset(key);
        offsetCompleter.complete();
      });
      await offsetCompleter.future;
    });
    return scrollCompleter.future;
  }

  /// Called when user presses "Find post in the tree" from parent post preview.
  void scrollToParent(TreeNode<Post> node, int tabId) async {
    scrollToNode(node, tabId, forcedDirection: AxisDirection.up);
  }

  /// Called when user presses "Find post in the tree" from [EndDrawer].
  /// We don't have post node pointer in [EndDrawer] post so we have to get it
  /// in order to obtain [PostWidget] global key.
  ///
  /// [tabId] stands for id of the tab where scroll needs to be performed.
  /// It needs to obtain corrent global key of the [PostWidget] we want to
  /// scroll to because the same [PostWidget] on [ThreadScreen] and on
  /// [BranchScreen] has different global key.
  // TODO: add find parent to search in current root
  void scrollToNodeByPost(
      Post post, List<TreeNode<Post>> roots, int tabId) async {
    final TreeNode<Post> node = Tree.findNode(roots, post.id)!;
    late final TreeNode<Post> rootNode;

    Completer<void> expandCompleter = Completer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// Expand parent nodes so the renderObject of the node is visible
      rootNode = Tree.expandParentNodes(node);
      debugPrint('rootnode ${rootNode.data.id}');
      expandCompleter.complete();
    });
    await expandCompleter.future;
    AxisDirection? forcedDirection;

    if (rootNode.data.id > getFirstVisiblePost().node.data.id) {
      forcedDirection = AxisDirection.down;
      debugPrint('force down');
    } else {
      /// if equals then go up too
      forcedDirection = AxisDirection.up;
      debugPrint('force up');
    }

    final GlobalKey key = node.getGlobalKey(tabId);
    _scrollToNode(key, forcedDirection: forcedDirection);
  }

  /// Called when calling [scrollToParent()] or when you are not sure which
  /// direction to scroll in, yet you have node pointer of desired post.
  void scrollToNode(TreeNode<Post> node, int tabId,
      {AxisDirection? forcedDirection}) async {
    late final TreeNode<Post> rootNode;

    Completer<void> expandCompleter = Completer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      rootNode = Tree.expandParentNodes(node);
      debugPrint('rootnode ${rootNode.data.id}');
      expandCompleter.complete();
    });
    await expandCompleter.future;

    ///
    if (forcedDirection == null &&
        rootNode.data.id > getFirstVisiblePost().node.data.id) {
      forcedDirection = AxisDirection.down;
      debugPrint('force down');
    } else {
      // TODO: if in the same root, scroll till root post then scroll down if not found
      forcedDirection = AxisDirection.up;
      debugPrint('force up');
    }

    /// Expanding trees leads to visible posts offset.
    /// This may cause problems while finding post.
    // await updateScrollPosition();
    final GlobalKey key = node.getGlobalKey(tabId);
    _scrollToNode(key, forcedDirection: forcedDirection);
  }

  /// Actual scroll function.
  void _scrollToNode(GlobalKey key, {AxisDirection? forcedDirection}) async {
    /// Store initial scroll in order to jump to it later before looking down
    /// (if we haven't found node during scrolling up)
    final double initialScrollPosition = _scrollController.offset;
    if (await scrollToNodeInDirection(key,
        direction: forcedDirection ?? AxisDirection.up)) {
      return;
    } else {
      Completer<void> jumpCompleter = Completer();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(initialScrollPosition);
        jumpCompleter.complete();
      });
      await jumpCompleter.future;

      await scrollToNodeInDirection(key, direction: AxisDirection.down);
      return;
    }
  }
}
