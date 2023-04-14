import 'package:flutter/material.dart';
import 'package:treechan/services/image_download_service.dart';

import '../../models/json/json.dart';
import 'package:extended_image/extended_image.dart';

import 'image_gallery_widget.dart';
import 'video_player_widget.dart';

/// Scrollable horizontal row with image previews.
class MediaPreview extends StatelessWidget {
  const MediaPreview({Key? key, required this.files}) : super(key: key);
  final List<File>? files;
  @override
  Widget build(BuildContext context) {
    fixLinks(files);
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

void fixLinks(List<File>? files) {
  if (files == null) {
    return;
  }
  for (var file in files) {
    if (file.thumbnail != null && !file.thumbnail!.contains("http")) {
      file.thumbnail = "https://2ch.hk${file.thumbnail}";
    }
    if (file.path != null && !file.path!.contains("http")) {
      file.path = "https://2ch.hk${file.path}";
    }
  }
}

List<int> _galleryTypes = [1, 2, 4]; // jpg png gif respectively
List<int> _videoTypes = [6, 10]; // webm mp4

List<Widget> _getImages(List<File>? files, BuildContext context) {
  if (files == null) {
    // return empty image list
    return List<Widget>.filled(1, const SizedBox.shrink());
  }

  List<Widget> media = List<Widget>.empty(growable: true);
  List<String> fullResLinks = List<String>.empty(growable: true);
  List<String> videoLinks = List<String>.empty(growable: true);

  for (var file in files) {
    if (_galleryTypes.contains(file.type)) {
      fullResLinks.add(file.path!);
    } else if (_videoTypes.contains(file.type)) {
      videoLinks.add(file.path!);
    }
  }
  for (var file in files) {
    media.add(_MediaItemPreview(
        imageLinks: fullResLinks,
        file: file,
        context: context,
        type: file.type!));
  }
  return media;
}

/// Represents one specific media item in a row.
class _MediaItemPreview extends StatefulWidget {
  const _MediaItemPreview(
      {Key? key,
      required this.imageLinks,
      required this.file,
      required this.context,
      required this.type})
      : super(key: key);

  final List<String> imageLinks;
  final File file;
  final BuildContext context;
  final int type;
  @override
  State<_MediaItemPreview> createState() => _MediaItemPreviewState();
}

class _MediaItemPreviewState extends State<_MediaItemPreview>
    with SingleTickerProviderStateMixin {
  ImageDownloadService imageDownloadService = ImageDownloadService();

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.imageLinks.indexOf(widget.file.path!);
    final pageController = ExtendedPageController(initialPage: currentIndex);

    return GestureDetector(
      onTap: () => Navigator.push(
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
                      imageDownloadService.downloadImage();
                      // fix infinite duration

                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(
                      //     content: Text("Загружено"),
                      //     behavior: SnackBarBehavior.floating,
                      //     duration: Duration(seconds: 3),
                      //     elevation: 0,
                      //   ),
                      // );
                    },
                    // add a notification here to show that the image is downloaded
                  )
                ],
              ),
              body: (_galleryTypes.contains(widget.type))
                  ? SwipeGallery(
                      imageLinks: widget.imageLinks,
                      pageController: pageController,
                      onDownloadImage: (imageUrl, fileName) {
                        imageDownloadService.setUrl(url: imageUrl);
                      },
                    )
                  : VideoPlayer(file: widget.file)),
        ),
      ),
      child: getThumbnail(widget.type),
    );
  }

  Widget getThumbnail(int type) {
    if (_galleryTypes.contains(type)) {
      return Image.network(
        widget.file.thumbnail!,
        height: 140,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(
              height: 140, width: 140, child: Text("bad image"));
        },
      );
    } else if (_videoTypes.contains(type)) {
      return Stack(children: [
        Image.network(
          widget.file.thumbnail!,
          height: 140,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox(
                height: 140, width: 140, child: Text("bad video"));
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
