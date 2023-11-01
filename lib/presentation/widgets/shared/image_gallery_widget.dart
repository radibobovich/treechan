import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:treechan/domain/imageboards/imageboard_specific.dart';
import 'dart:math';

import 'package:treechan/domain/models/core/file.dart';
import 'package:treechan/presentation/widgets/shared/video_player_widget.dart';
import 'package:treechan/utils/constants/enums.dart';

typedef DoubleClickAnimationListener = void Function();

/// A gallery that opens when user tap on image preview.
class SwipeGallery extends StatefulWidget {
  const SwipeGallery({
    super.key,
    required this.imageboard,
    required this.files,
    required this.pageController,
  });
  final Imageboard imageboard;
  final List<File> files;

  final ExtendedPageController pageController;

  @override
  State<SwipeGallery> createState() => _SwipeGalleryState();
}

class _SwipeGalleryState extends State<SwipeGallery>
    with TickerProviderStateMixin {
  late AnimationController _doubleClickAnimationController;
  Animation<double>? _doubleClickAnimation;
  late DoubleClickAnimationListener _doubleClickAnimationListener;
  List<double> doubleTapScales = <double>[1.0, 2.0];

  @override
  void initState() {
    super.initState();
    _doubleClickAnimationController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadImage(1);
  }

  @override
  void dispose() {
    _doubleClickAnimationController.dispose();
    _doubleClickAnimation?.removeListener(_doubleClickAnimationListener);
    super.dispose();
  }

  final List<int> _cachedIndexes = <int>[];

  void _preloadImage(int index) {
    if (_cachedIndexes.contains(index)) return;

    if (0 <= index && index < widget.files.length) {
      /// Don't precache videos
      if (!ImageboardSpecific(widget.imageboard)
          .imageTypes
          .contains(widget.files[index].type)) {
        return;
      }
      final String url = widget.files[index].path;

      precacheImage(ExtendedNetworkImageProvider(url, cache: true), context);

      _cachedIndexes.add(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedImageSlidePage(
      slideAxis: SlideAxis.vertical,
      slideType: SlideType.onlyImage,
      slidePageBackgroundHandler: (offset, pageSize) {
        double opacity = 0.0;
        opacity = offset.dy.abs() / (pageSize.width / 2.0);
        return Colors.black.withOpacity(min(1.0, max(1.0 - opacity, 0.0)));
      },
      child: ExtendedImageGesturePageView.builder(
        physics: widget.files.length == 1
            ? const NeverScrollableScrollPhysics()
            : const ClampingScrollPhysics(),
        onPageChanged: (int page) {
          _preloadImage(page - 1);
          _preloadImage(page + 1);
        },
        itemBuilder: (context, index) {
          return Builder(builder: (context) {
            if (ImageboardSpecific(widget.imageboard)
                .imageTypes
                .contains(widget.files[index].type)) {
              return ExtendedImage.network(
                widget.files[index].path,
                fit: BoxFit.contain,
                enableSlideOutPage: true,
                mode: ExtendedImageMode.gesture,
                initGestureConfigHandler: (state) {
                  return GestureConfig(
                    inPageView: true,
                    initialScale: 1.0,
                    minScale: 1.0,
                    animationMinScale: 0.7,
                    maxScale: 3.0,
                    animationMaxScale: 3.5,
                    speed: 1.0,
                    inertialSpeed: 100.0,
                    initialAlignment: InitialAlignment.center,
                  );
                },
                loadStateChanged: (state) {
                  if (state.extendedImageLoadState == LoadState.loading) {
                    final ImageChunkEvent? loadingProgress =
                        state.loadingProgress;
                    final double? progress =
                        loadingProgress?.expectedTotalBytes != null
                            ? loadingProgress!.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null;
                    return Stack(
                      alignment: AlignmentDirectional.center,
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.files[index].thumbnail,
                          fit: BoxFit.contain,
                        ),
                        Center(
                            child: CircularProgressIndicator(value: progress)),
                      ],
                    );
                  } else if (state.extendedImageLoadState == LoadState.failed) {
                    return Image.network(
                      widget.files[index].thumbnail,
                      fit: BoxFit.contain,
                    );
                  }
                  return null;
                },
                onDoubleTap: (state) {
                  final Offset? pointerDownPosition = state.pointerDownPosition;
                  final double? begin = state.gestureDetails!.totalScale;
                  double end;

                  //remove old
                  _doubleClickAnimation
                      ?.removeListener(_doubleClickAnimationListener);

                  //stop pre
                  _doubleClickAnimationController.stop();

                  //reset to use
                  _doubleClickAnimationController.reset();

                  if (begin == doubleTapScales[0]) {
                    end = doubleTapScales[1];
                  } else {
                    end = doubleTapScales[0];
                  }

                  _doubleClickAnimationListener = () {
                    //print(_animation.value);
                    state.handleDoubleTap(
                        scale: _doubleClickAnimation!.value,
                        doubleTapPosition: pointerDownPosition);
                  };
                  _doubleClickAnimation = _doubleClickAnimationController
                      .drive(Tween<double>(begin: begin, end: end));

                  _doubleClickAnimation!
                      .addListener(_doubleClickAnimationListener);

                  _doubleClickAnimationController.forward();
                },
              );
            } else if (ImageboardSpecific(widget.imageboard)
                .videoTypes
                .contains(widget.files[index].type)) {
              return VideoPlayer(file: widget.files[index]);
            }
            return const SizedBox.shrink();
          });
        },
        itemCount: widget.files.length,
        controller: widget.pageController,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
