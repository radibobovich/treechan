import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'dart:math';

typedef DoubleClickAnimationListener = void Function();

/// A gallery that opens when user tap on image preview.
class SwipeGallery extends StatefulWidget {
  const SwipeGallery({
    super.key,
    required this.imageLinks,
    required this.previewLinks,
    required this.pageController,
  });

  final List<String> imageLinks;
  final List<String> previewLinks;
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
    if (_cachedIndexes.contains(index)) {
      return;
    }
    if (0 <= index && index < widget.imageLinks.length) {
      final String url = widget.imageLinks[index];

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
        physics: widget.imageLinks.length == 1
            ? const NeverScrollableScrollPhysics()
            : const ClampingScrollPhysics(),
        onPageChanged: (int page) {
          _preloadImage(page - 1);
          _preloadImage(page + 1);
        },
        itemBuilder: (context, index) {
          return ExtendedImage.network(
            widget.imageLinks[index],
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
                final ImageChunkEvent? loadingProgress = state.loadingProgress;
                final double? progress =
                    loadingProgress?.expectedTotalBytes != null
                        ? loadingProgress!.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null;
                return Stack(
                  alignment: AlignmentDirectional.center,
                  fit: StackFit.expand,
                  children: [
                    ExtendedImage.network(
                      mode: ExtendedImageMode.none,
                      widget.previewLinks[index],
                      fit: BoxFit.contain,
                      loadStateChanged: (state) {
                        if (state.extendedImageLoadState ==
                            LoadState.completed) {
                          return null;
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                    Center(child: CircularProgressIndicator(value: progress)),
                  ],
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

              _doubleClickAnimation!.addListener(_doubleClickAnimationListener);

              _doubleClickAnimationController.forward();
            },
          );
        },
        itemCount: widget.imageLinks.length,
        controller: widget.pageController,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
