import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'dart:math';

class SwipeGallery extends StatelessWidget {
  const SwipeGallery(
      {super.key,
      required this.imageLinks,
      required this.pageController,
      required this.onDownloadImage});

  final List<String> imageLinks;
  final ExtendedPageController pageController;
  final Function onDownloadImage;
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
          onDownloadImage(imageLinks[index], index);
          return ExtendedImage.network(
            imageLinks[index],
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
        itemCount: imageLinks.length,
        controller: pageController,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
