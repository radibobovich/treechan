import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../models/json/post_json.dart';
import '../widgets/thread/post_widget.dart';

/// A service generally to scroll to a post after thread refresh.
class ScrollService {
  List<PostWidget> visiblePosts = List.empty(growable: true);
  List<PostWidget> partiallyVisiblePosts = List.empty(growable: true);

  final ScrollController _scrollController;
  final double _screenHeight;
  ScrollService(this._scrollController, this._screenHeight);

  PostWidget? _firstVisiblePost;
  double? _initialOffset;

  /// Saves current first visible post and its offset before thread refresh.
  void saveCurrentScrollInfo() async {
    _firstVisiblePost = _getFirstVisiblePost();
    _initialOffset = _getInitialOffset(_firstVisiblePost!);
  }

  /// Sorts visible posts by its position and returns the topmost.
  PostWidget _getFirstVisiblePost() {
    Map<PostWidget, double> posts = {};
    for (PostWidget post in visiblePosts) {
      RenderObject? obj =
          (post.key as GlobalKey).currentContext?.findRenderObject();
      RenderBox? box = obj != null ? obj as RenderBox : null;
      Offset? position = box?.localToGlobal(Offset.zero);
      double? y = position?.dy;
      if (y != null) {
        posts[post] = y;
      }
    }
    Map<PostWidget, double> sortedByOffset = Map.fromEntries(
        posts.entries.toList()..sort((e1, e2) => e1.value.compareTo(e2.value)));
    // for debugging
    List<String> visibleIds = [];
    for (PostWidget post in visiblePosts) {
      visibleIds.add(post.node.data.id!.toString());
    }
    if (sortedByOffset.isEmpty) {
      return partiallyVisiblePosts.first;
    }
    return sortedByOffset.keys.first;
  }

  /// Gets offset of the post relative to the top of the screen.
  double? _getInitialOffset(PostWidget post) {
    RenderObject? obj;
    RenderBox? box;
    obj = (post.key as GlobalKey).currentContext?.findRenderObject(); // null
    box = obj != null ? obj as RenderBox : null;
    Offset? position = box?.localToGlobal(Offset.zero);
    return position?.dy;
  }

  /// Scrolls down until the post that was at the top of the screen
  /// returns to its place.
  Future<void> updateScrollPosition() async {
    RenderObject? obj;
    RenderBox? box;
    Offset? position;
    double? currentOffset;
    Completer<void> completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      obj = (_firstVisiblePost!.key as GlobalKey)
          .currentContext
          ?.findRenderObject(); // null
      box = obj != null ? obj as RenderBox : null;
      position = box?.localToGlobal(Offset.zero);
      currentOffset = position?.dy;
      completer.complete();
    });
    await completer.future;
    if (currentOffset == _initialOffset) {
      return;
    }
    Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (currentOffset != null &&
          (currentOffset! < _initialOffset! + 20 ||
              currentOffset! > _initialOffset! - 20)) {
        timer.cancel();
      }
      if (currentOffset == null) {
        // https://stackoverflow.com/questions/49553402/how-to-determine-screen-height-and-width
        _scrollController.animateTo(_scrollController.offset + _screenHeight,
            duration: const Duration(milliseconds: 50), curve: Curves.easeOut);
      } else {
        _scrollController.animateTo(
            _scrollController.offset + (currentOffset! - _initialOffset!),
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut);
        timer.cancel();
      }
      obj = (_firstVisiblePost!.key as GlobalKey)
          .currentContext
          ?.findRenderObject();
      box = obj != null ? obj as RenderBox : null;
      position = box?.localToGlobal(Offset.zero);
      currentOffset = position?.dy;
    });

    return;
  }

  void checkVisibility(
      {required PostWidget widget,
      required VisibilityInfo visibilityInfo,
      required Post post}) {
    if (true) {
      if (visibilityInfo.visibleFraction == 1) {
        debugPrint("Post ${post.id} is visible, key is $widget.key");
        if (!visiblePosts.contains(widget)) {
          visiblePosts.add(widget);
        }
      }
      if (visibilityInfo.visibleFraction < 1 && visiblePosts.contains(widget)) {
        debugPrint("Post ${post.id} is invisible");
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
}
