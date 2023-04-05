import 'package:flutter/material.dart';

import '../models/json/json.dart';
import 'package:extended_image/extended_image.dart';

import 'image_gallery_widget.dart';
import 'video_player_widget.dart';

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

List<int> _galleryTypes = [1, 2, 4];
List<int> _videoTypes = [6, 10];

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
      fullResLinks.add("https://2ch.hk${file.path ?? ""}");
    } else if (_videoTypes.contains(file.type)) {
      videoLinks.add("https://2ch.hk${file.path ?? ""}");
    }
  }
  for (var file in files) {
    media.add(MediaPreview(
        imageLinks: fullResLinks,
        file: file,
        context: context,
        type: file.type!));
  }
  return media;
}

class MediaPreview extends StatefulWidget {
  const MediaPreview(
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
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final currentIndex =
        widget.imageLinks.indexOf("https://2ch.hk${widget.file.path ?? ""}");
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
              ),
              body: (_galleryTypes.contains(widget.type))
                  ? SwipeGallery(
                      imageLinks: widget.imageLinks,
                      pageController: pageController)
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
