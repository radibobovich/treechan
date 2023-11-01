import 'dart:math';

import 'package:flutter/material.dart';
import 'package:treechan/di/injection.dart';
import 'package:treechan/domain/imageboards/imageboard_specific.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/domain/services/image_download_service.dart';

import 'package:extended_image/extended_image.dart';
import 'package:treechan/utils/constants/dev.dart';
import 'package:treechan/utils/constants/enums.dart';

import 'image_gallery_widget.dart';

/// Scrollable horizontal row with image previews.
class MediaPreview extends StatelessWidget {
  const MediaPreview({
    Key? key,
    required this.files,
    required this.imageboard,
    this.height = 140,
    this.singleImage = false,
  }) : super(key: key);
  final List<File>? files;
  final Imageboard imageboard;
  final double height;

  /// If true, preview gallery will be limited to one image.
  final bool singleImage;
  @override
  Widget build(BuildContext context) {
    if (files == null || files!.isEmpty) return const SizedBox.shrink();
    _fixLinks(files!);
    if (env == Env.test || env == Env.dev) {
      _mockLinks(files!);
    }
    return Padding(
      padding:
          (files == null ? const EdgeInsets.all(0) : const EdgeInsets.all(8.0)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: singleImage
            ? const NeverScrollableScrollPhysics()
            : const ClampingScrollPhysics(),
        child: Row(
          children: _getImages(files!, imageboard, context,
              height: height, singleImage: singleImage),
        ),
      ),
    );
  }
}

void _fixLinks(List<File> files) {
  for (var file in files) {
    if (!file.thumbnail.contains("http")) {
      file.thumbnail = "https://2ch.hk${file.thumbnail}";
    }
    if (!file.path.contains("http")) {
      file.path = "https://2ch.hk${file.path}";
    }
  }
}

/// Used for testing purposes
void _mockLinks(List<File> files) {
  for (var file in files) {
    file.thumbnail = mockImages[Random().nextInt(mockImages.length)];
  }
}

List<Widget> _getImages(
    List<File> files, Imageboard imageboard, BuildContext context,
    {required double height, bool singleImage = false}) {
  List<Widget> media = [];
  List<File> allowedFiles = [];
  // List<String> fullResLinks = [];
  // List<String> previewLinks = [];
  // List<String> videoLinks = [];

  for (var file in files) {
    if (ImageboardSpecific(imageboard).imageTypes.contains(file.type) ||
        ImageboardSpecific(imageboard).videoTypes.contains(file.type)) {
      // fullResLinks.add(file.path);
      allowedFiles.add(file);
      // previewLinks.add(file.thumbnail);
    }
    // else if (ImageboardSpecific(imageboard).videoTypes.contains(file.type)) {
    //   videoLinks.add(file.path);
    // }
  }
  for (var file in allowedFiles) {
    if (singleImage && media.length == 1) break;
    media.add(_MediaItemPreview(
      imageboard: imageboard,
      // imageLinks: fullResLinks,
      // videoLinks: videoLinks,
      // previewLinks: previewLinks,
      file: file,
      files: allowedFiles,
      // type: file.type,
      height: height,
      singleImage: singleImage,
    ));
  }
  return media;
}

/// Represents one specific media item in a row.
class _MediaItemPreview extends StatefulWidget {
  const _MediaItemPreview({
    Key? key,
    required this.imageboard,
    required this.file,
    required this.files,
    required this.height,
    required this.singleImage,
  }) : super(key: key);

  final Imageboard imageboard;
  final File file;
  final List<File> files;
  final double height;
  final bool singleImage;
  @override
  State<_MediaItemPreview> createState() => _MediaItemPreviewState();
}

class _MediaItemPreviewState extends State<_MediaItemPreview>
    with SingleTickerProviderStateMixin {
  late Widget thumbnail;
  bool isLoaded = true;

  @override
  void initState() {
    super.initState();
    thumbnail = getThumbnail(widget.file.type);
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = widget.files.indexOf(widget.file);
    final pageController = ExtendedPageController(initialPage: currentIndex);

    return GestureDetector(
      key: ObjectKey(thumbnail),
      onTap: () => isLoaded
          ? openGallery(context, pageController, currentIndex)
          : reloadThumbnail(),
      child: thumbnail,
    );
  }

  void reloadThumbnail() {
    thumbnail = getThumbnail(widget.file.type);
    if (thumbnail.runtimeType == Image) {
      isLoaded = true;
    }
    setState(() {});
  }

  Future<dynamic> openGallery(
      BuildContext context, ExtendedPageController pageController, int index) {
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
                    ImageboardSpecific(widget.imageboard)
                            .videoTypes
                            .contains(widget.files[index].type)
                        ? downloadVideo(widget.files[index].path)
                        : downloadImage(
                            widget.files[index].path,
                          );
                  },
                  // add a notification here to show that the image is downloaded
                )
              ],
            ),
            body: SwipeGallery(
              imageboard: widget.imageboard,
              files: widget.files,
              pageController: pageController,
            )),
      ),
    );
  }

  Widget getThumbnail(int type) {
    if (ImageboardSpecific(widget.imageboard).imageTypes.contains(type)) {
      return Stack(
        children: [
          Image.network(
            widget.file.thumbnail,
            height: widget.height,
            width: widget.singleImage
                ? widget.height
                : widget.height *
                    widget.file.width.toDouble() /
                    widget.file.height.toDouble(),
            fit: widget.singleImage ? BoxFit.cover : BoxFit.fill,
            errorBuilder: (context, error, stackTrace) {
              isLoaded = false;
              return SizedBox(
                  height: widget.height,
                  width: widget.height,
                  child: const Icon(Icons.image_not_supported));
            },
          ),
          widget.singleImage && widget.files.length > 1
              ? Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    height: widget.height / 4,
                    width: widget.height / 4,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(142, 33, 33, 33),
                      borderRadius:
                          BorderRadius.only(bottomLeft: Radius.circular(3)),
                    ),
                    child: Center(
                        child: Text(
                      widget.files.length.toString(),
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(202, 204, 204, 204)),
                    )),
                  ))
              : const SizedBox.shrink()
        ],
      );
    } else if (ImageboardSpecific(widget.imageboard)
        .videoTypes
        .contains(type)) {
      return Stack(children: [
        Image.network(
          widget.file.thumbnail,
          height: widget.height,
          width: widget.singleImage ? widget.height : null,
          fit: widget.singleImage ? BoxFit.cover : BoxFit.fill,
          errorBuilder: (context, error, stackTrace) {
            return SizedBox(
                height: widget.height,
                width: widget.height,
                child: const Icon(Icons.image_not_supported));
          },
        ),
        const Positioned.fill(
          child: Center(
            child: Icon(Icons.play_arrow, size: 50, color: Colors.white),
          ),
        )
      ]);
    }
    return const SizedBox.shrink();
  }

  Image getFullRes(int index) {
    return Image.network(widget.files[index].path);
  }
}
