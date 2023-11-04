import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:treechan/domain/imageboards/imageboard_specific.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/domain/services/image_download_service.dart';
import 'package:treechan/presentation/widgets/shared/image_gallery_widget.dart';
import 'package:treechan/utils/constants/enums.dart';

Future<dynamic> openFullscreenGallery(
    BuildContext context, ExtendedPageController pageController,
    {required Imageboard imageboard, required List<File> files}) {
  return Navigator.push(
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
          // black background if video
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () {
                  final index = pageController.page?.toInt();
                  if (index == null) return;
                  ImageboardSpecific(imageboard)
                          .videoTypes
                          .contains(files[index].type)
                      ? downloadVideo(files[index].path)
                      : downloadImage(
                          files[index].path,
                        );
                },
                // add a notification here to show that the image is downloaded
              )
            ],
          ),
          body: SwipeGallery(
            imageboard: imageboard,
            files: files,
            pageController: pageController,
          )),
    ),
  );
}
