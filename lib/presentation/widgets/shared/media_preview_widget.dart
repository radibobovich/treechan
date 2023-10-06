import 'dart:math';

import 'package:flutter/material.dart';
import 'package:treechan/di/injection.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/domain/services/image_download_service.dart';

import 'package:extended_image/extended_image.dart';

import 'image_gallery_widget.dart';
import 'video_player_widget.dart';

/// Scrollable horizontal row with image previews.
class MediaPreview extends StatelessWidget {
  const MediaPreview({Key? key, required this.files, this.height = 140})
      : super(key: key);
  final List<File>? files;
  final double height;
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
        physics: const ClampingScrollPhysics(),
        child: Row(
          children: _getImages(files!, context, height: height),
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
  final List<String> mockImages = [
    'https://2ch.hk/abu/thumb/42375/14433751460020s.jpg',
    'https://2ch.hk/abu/thumb/52084/14760211194610s.jpg',
    'https://2ch.hk/abu/thumb/50159/14713521951590s.jpg',
    'https://2ch.hk/abu/thumb/39173/14229147201130s.jpg',
  ];
  for (var file in files) {
    file.thumbnail = mockImages[Random().nextInt(mockImages.length)];
  }
}

List<int> _galleryTypes = [0, 1, 2, 4, 9]; // none jpg png gif jpg respectively
List<int> _videoTypes = [6, 10]; // webm mp4

List<Widget> _getImages(List<File> files, BuildContext context,
    {required double height}) {
  List<Widget> media = [];
  List<String> fullResLinks = [];
  List<String> previewLinks = [];
  List<String> videoLinks = [];

  for (var file in files) {
    if (_galleryTypes.contains(file.type)) {
      fullResLinks.add(file.path);
      previewLinks.add(file.thumbnail);
    } else if (_videoTypes.contains(file.type)) {
      videoLinks.add(file.path);
    }
  }
  for (var file in files) {
    media.add(_MediaItemPreview(
      imageLinks: fullResLinks,
      videoLinks: videoLinks,
      previewLinks: previewLinks,
      file: file,
      type: file.type,
      height: height,
    ));
  }
  return media;
}

/// Represents one specific media item in a row.
class _MediaItemPreview extends StatefulWidget {
  const _MediaItemPreview({
    Key? key,
    required this.imageLinks,
    required this.videoLinks,
    required this.previewLinks,
    required this.file,
    required this.type,
    required this.height,
  }) : super(key: key);

  final List<String> imageLinks;
  final List<String> videoLinks;
  final List<String> previewLinks;
  final File file;
  final int type;
  final double height;
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
    thumbnail = getThumbnail(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = widget.imageLinks.indexOf(widget.file.path);
    bool isVideo = false;
    if (currentIndex == -1) {
      currentIndex = widget.videoLinks.indexOf(widget.file.path);
      isVideo = true;
    }
    final pageController = ExtendedPageController(initialPage: currentIndex);

    return GestureDetector(
      key: ObjectKey(thumbnail),
      onTap: () => isLoaded
          ? openGallery(context, pageController, currentIndex, isVideo)
          : reloadThumbnail(),
      child: thumbnail,
    );
  }

  void reloadThumbnail() {
    thumbnail = getThumbnail(widget.type);
    if (thumbnail.runtimeType == Image) {
      isLoaded = true;
    }
    setState(() {});
  }

  Future<dynamic> openGallery(BuildContext context,
      ExtendedPageController pageController, int index, bool isVideo) {
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
            backgroundColor: _galleryTypes.contains(widget.type)
                ? Colors.transparent
                : Colors.black,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () {
                    isVideo
                        ? downloadVideo(widget.videoLinks[index])
                        : downloadImage(
                            widget.imageLinks[index],
                          );
                  },
                  // add a notification here to show that the image is downloaded
                )
              ],
            ),
            body: (_galleryTypes.contains(widget.type))
                ? SwipeGallery(
                    imageLinks: widget.imageLinks,
                    previewLinks: widget.previewLinks,
                    pageController: pageController,
                  )
                : VideoPlayer(file: widget.file)),
      ),
    );
  }

  Widget getThumbnail(int type) {
    if (_galleryTypes.contains(type)) {
      return Image.network(
        widget.file.thumbnail,
        height: widget.height,
        width: widget.height *
            widget.file.width.toDouble() /
            widget.file.height.toDouble(),
        fit: BoxFit.fill,
        errorBuilder: (context, error, stackTrace) {
          isLoaded = false;
          return const SizedBox(
              height: 140, width: 140, child: Icon(Icons.image_not_supported));
        },
      );
    } else if (_videoTypes.contains(type)) {
      return Stack(children: [
        Image.network(
          widget.file.thumbnail,
          height: 140,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox(
                height: 140,
                width: 140,
                child: Icon(Icons.image_not_supported));
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
    return Image.network(widget.imageLinks[index]);
  }
}
