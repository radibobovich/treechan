import 'dart:async';
import 'dart:ui';

import 'package:flexible_tree_view/flexible_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../presentation/widgets/thread/post_widget.dart';
import '../models/core/core_models.dart';
import '../models/tree.dart';

/// A service generally to scroll to a post after thread refresh.
class ScrollService {
  List<dynamic> visiblePosts = List.empty(growable: true);
  // TODO: dont keep partially visible posts, determine is post visible using visibleBounds.center
  List<dynamic> partiallyVisiblePosts = List.empty(growable: true);

  final ScrollController _scrollController;
  final double _screenHeight;
  ScrollService(this._scrollController)
      : _screenHeight =
            (PlatformDispatcher.instance.implicitView!.physicalSize /
                    PlatformDispatcher.instance.implicitView!.devicePixelRatio)
                .height;

  PostWidget? _firstVisiblePost;
  double? _initialPostOffset;

  /// Saves current first visible post and its offset before thread refresh.
  void saveCurrentScrollInfo() async {
    _firstVisiblePost = getFirstVisiblePost();
    _initialPostOffset = _getPostOffset(_firstVisiblePost!.key!);
  }

  /// Sorts visible posts by its position and returns the topmost.
  PostWidget getFirstVisiblePost() {
    Map<PostWidget, double> posts = {};
    for (PostWidget post in visiblePosts) {
      double? y = _getPostOffset(post.key!);
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

  /// Gets vertical absolute offset of the post.
  double? _getPostOffset(Key key) {
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
    double? currentPostOffset;
    // Completer<void> completer = Completer<void>();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   currentPostOffset = _getPostOffset(_firstVisiblePost!.key!);
    //   completer.complete();
    // });
    // await completer.future;
    currentPostOffset = _getPostOffset(_firstVisiblePost!.key!);

    /// Don't update scroll position if visible post hasn't been moved during refresh.
    if (currentPostOffset == _initialPostOffset) {
      return;
    }
    Timer.periodic(const Duration(milliseconds: 60), (timer) {
      // if (currentOffset != null &&
      //     (currentOffset! < _initialOffset! + 20 ||
      //         currentOffset! > _initialOffset! - 20)) {
      //   timer.cancel();
      // }
      if (currentPostOffset == null) {
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
      currentPostOffset = _getPostOffset(_firstVisiblePost!.key!);
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

    /// TODO: find out if post frame callback is needed at all
    if (_scrollController.offset !=
        _scrollController.position.maxScrollExtent) {
      debugPrint(
          'scrollToNodeInDirection() offset is ${_scrollController.offset}');
      Completer<void> offsetCompleter = Completer();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        currentOffset = _getPostOffset(key);
        offsetCompleter.complete();
      });
      await offsetCompleter.future;
    } else {
      currentOffset = _getPostOffset(key);
    }
    Timer.periodic(const Duration(milliseconds: 60), (timer) async {
      if (currentOffset == null) {
        if ((direction == AxisDirection.up && _scrollController.offset == 0) ||
            (direction == AxisDirection.down &&
                _scrollController.offset ==
                    _scrollController.position.maxScrollExtent)) {
          debugPrint(
              'scrollToNodeInDirection() has reached max scroll extent, direction was ${direction.toString()}');
          timer.cancel();
          scrollCompleter.complete(false);
          return;
        }
        _scrollController.animateTo(_scrollController.offset + offsetModifier,
            duration: const Duration(milliseconds: 20), curve: Curves.easeOut);
      } else {
        debugPrint(
            'scrollToNodeInDirection() found the node, performing ensureVisible()...');
        timer.cancel();
        Scrollable.ensureVisible(key.currentContext!,
            duration: const Duration(milliseconds: 30), curve: Curves.easeOut);
        scrollCompleter.complete(true);
        return;
      }
      Completer<void> offsetCompleter = Completer();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        currentOffset = _getPostOffset(key);
        offsetCompleter.complete();
      });
      await offsetCompleter.future;
    });
    await scrollCompleter.future;
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
  void scrollToNodeByPost(Post post, int tabId,
      {List<TreeNode<Post>>? roots,
      Map<int, List<TreeNode<Post>>>? plainNodes}) async {
    assert(roots != null || plainNodes != null, 'roots or plainNodes is null');
    final TreeNode<Post> node;
    if (roots == null) {
      node = plainNodes![post.id]!.first;
    } else {
      node = Tree.findNode(roots, post.id)!;
    }
    // final TreeNode<Post> node = Tree.findNode(roots, post.id)!;
    late final TreeNode<Post> rootNode;

    if (_scrollController.offset == 0) {
      _scrollController.animateTo(10,
          duration: const Duration(milliseconds: 16), curve: Curves.easeOut);
    }
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
      debugPrint('scrollToNodeByPost() selected force down');
    } else {
      /// if equals then go up too
      forcedDirection = AxisDirection.up;
      debugPrint('scrollToNodeByPost() selected force up');
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

    if (forcedDirection == null &&
        rootNode.data.id > getFirstVisiblePost().node.data.id) {
      forcedDirection = AxisDirection.down;
      debugPrint('scrollToNode() selected force down');
    } else if (forcedDirection == null) {
      // TODO: if in the same root, scroll till root post then scroll down if not found
      forcedDirection = AxisDirection.up;
      debugPrint('scrollToNode() selected force up');
    } else {
      debugPrint(
          'scrollToNode() is using pre-defined scroll direction: ${forcedDirection.toString()}');
    }

    /// Expanding trees leads to visible posts offset.
    /// This may cause problems while finding post.
    // await updateScrollPosition();
    final GlobalKey key = node.getGlobalKey(tabId);
    debugPrint('scrollToNode() got node key $key');
    _scrollToNode(key, forcedDirection: forcedDirection);
  }

  /// Actual scroll function.
  void _scrollToNode(GlobalKey key, {AxisDirection? forcedDirection}) async {
    /// Store initial scroll in order to jump to it later before looking down
    /// (if we haven't found node during scrolling up)
    final double initialScrollPosition = _scrollController.offset;
    if (await scrollToNodeInDirection(key,
        direction: forcedDirection ?? AxisDirection.up)) {
      debugPrint(
          '_scrollToNode() scrolled ${forcedDirection?.toString() ?? 'up'} and found the node.');
      return;
    } else {
      debugPrint('''
_scrollToNode() scrolled ${forcedDirection?.toString() ?? 'up'} but did not succeed.
Jumping to initial scroll position and trying to scroll in the opposite direction.''');
      Completer<void> jumpCompleter = Completer();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(initialScrollPosition);
        jumpCompleter.complete();
      });
      await jumpCompleter.future;
      final newDirection =
          forcedDirection == AxisDirection.up || forcedDirection == null
              ? AxisDirection.down
              : AxisDirection.up;
      await scrollToNodeInDirection(key, direction: newDirection);
      return;
    }
  }
}
