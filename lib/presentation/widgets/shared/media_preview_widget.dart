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

/// Size of media item preview in [_showGalleryPreviewDialog].
const double _dialogThumbnailDimension = 120;

/// Works as a srollable horizontal row with image thumbnails in [ThreadCard],
///
/// and in [ThreadCardClassic] works as a single square media preview that
/// opens a dialog window with all the media thumbnails once tapped.
class MediaPreview extends StatelessWidget {
  const MediaPreview({
    Key? key,
    required this.files,
    required this.imageboard,
    this.height = 140,
    this.classicPreview = false,
    this.showAsDialog = false,
  }) : super(key: key);
  final List<File>? files;
  final Imageboard imageboard;
  final double height;

  /// If true, displays gallery in a [Wrap] to adapt for dialog view.
  final bool showAsDialog;

  /// If true, preview gallery will be limited to one image. Used in [ThreadCardClassic].
  final bool classicPreview;

  @override
  Widget build(BuildContext context) {
    if (files == null || files!.isEmpty) return const SizedBox.shrink();
    _fixLinks(files!, imageboard);
    if (env == Env.test || env == Env.dev) {
      _mockLinks(files!);
    }
    return Builder(
      builder: (_) {
        if (showAsDialog) {
          final mediaItems = _getMediaItems(
            files!,
            imageboard,
            context,
            height: _dialogThumbnailDimension,
            classicPreview: classicPreview,
            squareShaped: true,
          );
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: mediaItems.length <= 2 ? mediaItems.length : 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: mediaItems.length,
            itemBuilder: (context, index) {
              return mediaItems[index];
            },
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: classicPreview
                  ? const NeverScrollableScrollPhysics()
                  : const ClampingScrollPhysics(),
              child: Row(
                children: _getMediaItems(files!, imageboard, context,
                    height: height, classicPreview: classicPreview),
              ),
            ),
          );
        }
      },
    );
  }
}

/// Picks attachments that are valid media files supported on the current
/// [Imageboard] and creates a list of [_MediaItemPreview].
///
/// The list will contain only one image if [classicPreview] is true.
List<Widget> _getMediaItems(
    List<File> files, Imageboard imageboard, BuildContext context,
    {required double height,
    bool classicPreview = false,
    bool squareShaped = false}) {
  List<Widget> media = [];
  List<File> allowedFiles = [];

  for (var file in files) {
    if (ImageboardSpecific(imageboard).imageTypes.contains(file.type) ||
        ImageboardSpecific(imageboard).videoTypes.contains(file.type)) {
      allowedFiles.add(file);
    }
  }
  for (var file in allowedFiles) {
    if (classicPreview && media.length == 1) break;
    media.add(_MediaItemPreview(
      imageboard: imageboard,
      file: file,
      files: allowedFiles,
      height: height,
      classicPreview: classicPreview,
      squareShaped: squareShaped,
    ));
  }
  return media;
}

/// Represents one specific media item.
class _MediaItemPreview extends StatefulWidget {
  const _MediaItemPreview({
    Key? key,
    required this.imageboard,
    required this.file,
    required this.files,
    required this.height,
    required this.classicPreview,
    this.squareShaped = false,
  }) : super(key: key);

  final Imageboard imageboard;
  final File file;
  final List<File> files;
  final double height;
  final bool classicPreview;
  final bool squareShaped;
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
      onTap: () {
        if (widget.classicPreview) {
          /// Dont open gallery dialog if there is a single media item.
          if (widget.files.length == 1) {
            _openFulscreenGallery(context, pageController);
            return;
          }
          _showGalleryPreviewDialog(context,
              imageboard: widget.imageboard,
              files: widget.files,
              dimension: _dialogThumbnailDimension);
          return;
        }

        if (isLoaded) {
          _openFulscreenGallery(context, pageController);
        } else {
          _reloadThumbnail();
        }
      },
      child: thumbnail,
    );
  }

  void _reloadThumbnail() {
    thumbnail = getThumbnail(widget.file.type);
    if (thumbnail.runtimeType == Image) {
      isLoaded = true;
    }
    setState(() {});
  }

  /// Gallery dialog for classic board view.
  ///
  /// Will be opened on user tap on the image preview
  /// from [ThreadCardClassic].
  void _showGalleryPreviewDialog(BuildContext context,
      {required Imageboard imageboard,
      required List<File> files,
      required double dimension}) {
    showDialog(
      context: context,
      builder: (_) {
        final length = files.length;
        final dialogHeight =
            length <= 2 ? dimension : dimension * (length / 2).ceil();
        final dialogWidth = length <= 2
            ? length * dimension + (length - 1) * 10
            : 2 * dimension + 10;
        final screenWidth = MediaQuery.of(context).size.width;
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(
              horizontal: ((screenWidth - dialogWidth) / 2 - 20)
                  .clamp(0, double.infinity)),
          contentPadding: const EdgeInsets.all(10),
          titlePadding: const EdgeInsets.all(0),

          /// Builds the same [MediaPreview] widget but now with [fromDialog]
          /// set to true.
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: dialogWidth,
                height: dialogHeight,
                child: LayoutBuilder(builder: (context, constraints) {
                  debugPrint(
                      'constraints width: ${constraints.maxWidth.toString()}');

                  return MediaPreview(
                    files: files,
                    imageboard: imageboard,
                    height: dimension,
                    classicPreview: false,
                    showAsDialog: true,
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<dynamic> _openFulscreenGallery(
      BuildContext context, ExtendedPageController pageController) {
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
            width: widget.classicPreview || widget.squareShaped
                ? widget.height
                : widget.height *
                    widget.file.width.toDouble() /
                    widget.file.height.toDouble(),
            fit: widget.classicPreview || widget.squareShaped
                ? BoxFit.cover
                : BoxFit.fill,
            errorBuilder: (context, error, stackTrace) {
              isLoaded = false;
              return SizedBox(
                  height: widget.height,
                  width: widget.height,
                  child: const Icon(Icons.image_not_supported));
            },
          ),

          /// Number of media items in the cornel of the thumbnail
          widget.classicPreview && widget.files.length > 1
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
          width: widget.classicPreview ? widget.height : null,
          fit: widget.classicPreview ? BoxFit.cover : BoxFit.fill,
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

void _fixLinks(List<File> files, Imageboard imageboard) {
  if (!(imageboard == Imageboard.dvach ||
      imageboard == Imageboard.dvachArchive)) {
    return;
  }
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
