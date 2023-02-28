import 'dart:math';
import 'package:flutter/material.dart';
import 'package:treechan/models/board_json.dart';
import 'package:extended_image/extended_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

/// Scrollable horizontal row with image previews.
class ImagesPreview extends StatelessWidget {
  const ImagesPreview({Key? key, required this.files}) : super(key: key);
  final List<File>? files;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          (files == null ? const EdgeInsets.all(0) : const EdgeInsets.all(8.0)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _getImages(files, context),
        ),
      ),
    );
  }
}

List<Widget> _getImages(List<File>? files, BuildContext context) {
  if (files == null) {
    // return empty image list
    return List<Widget>.filled(1, const SizedBox.shrink());
  }

  List<Widget> images = List<Widget>.empty(growable: true);
  List<String> fullResLinks = List<String>.empty(growable: true);
  List<int> supportedFormats = [1, 2, 4];

  for (var file in files) {
    if (supportedFormats.contains(file.type)) {
      fullResLinks.add("https://2ch.hk${file.path ?? ""}");
    }
  }
  for (var file in files) {
    if (supportedFormats.contains(file.type)) {
      images.add(
          ImagePreview(imageLinks: fullResLinks, file: file, context: context));
    }
  }
  return images;
}

class ImagePreview extends StatefulWidget {
  const ImagePreview(
      {Key? key,
      required this.imageLinks,
      required this.file,
      required this.context})
      : super(key: key);

  final List<String> imageLinks;
  final File file;
  final BuildContext context;

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final currentIndex =
        widget.imageLinks.indexOf("https://2ch.hk${widget.file.path ?? ""}");
    final pageController = ExtendedPageController(initialPage: currentIndex);

    return GestureDetector(
      onTap: () => widget.imageLinks.isNotEmpty
          ? Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 50),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                opaque: false,
                pageBuilder: (_, __, ___) => Scaffold(
                  backgroundColor: Colors.transparent,
                  extendBodyBehindAppBar: true,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  body: SwipeGallery(
                      widget: widget, pageController: pageController),
                ),
              ),
            )
          : () {},
      child: getThumbnail(),
    );
  }

  Image getThumbnail() {
    return Image.network(
      widget.file.thumbnail!,
      height: 140,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox(height: 140, width: 140, child: Text("error"));
      },
    );
  }

  Image getFullRes(int index) {
    return Image.network(widget.imageLinks[index]);
  }
}

class SwipeGallery extends StatelessWidget {
  const SwipeGallery({
    super.key,
    required this.widget,
    required this.pageController,
  });

  final ImagePreview widget;
  final ExtendedPageController pageController;
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
          );
        },
        itemCount: widget.imageLinks.length,
        controller: pageController,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}

// Future<ImageProvider> tryPrecache(
//   BuildContext context, {
//   Size? size,
//   required ImageProvider provider,
//   required ImageProvider fallback,
// }) async {
//   var failed = false;
//   await precacheImage(
//     provider,
//     context,
//     size: size,
//     onError: (_, __) => failed = true,
//   );
//   return failed ? fallback : provider;
// }
