import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:treechan/models/board_json.dart';
// import 'package:swipe_image_gallery/swipe_image_gallery.dart';
import 'package:photo_view/photo_view.dart';

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
  List<String> imageLinks = List<String>.empty(growable: true);
  List<int> supportedFormats = [1, 2, 4];

  for (var file in files) {
    if (supportedFormats.contains(file.type)) {
      imageLinks.add("https://2ch.hk${file.path ?? ""}");
      images.add(ImagePreview(
        imageLinks: [imageLinks.last],
        file: file,
        context: context,
      ));
    }
  }
  // for (var file in files) {
  //   if (supportedFormats.contains(file.type)) {
  //     images.add(
  //         ImagePreview(imageLinks: imageLinks, file: file, context: context));
  //   }
  // }
  return images;
}

class ImagePreview extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final index = imageLinks.indexOf("https://2ch.hk${file.path ?? ""}");
    final pageController = PageController(initialPage: index);

    return GestureDetector(
  //       onTap: () => imageLinks.isNotEmpty
  //           ? (SwipeImageGallery(
  //                   context: context,
  //                   itemBuilder: (context, index) {
  //                     return getImageFromNet(index);
  //                   },
  //                   itemCount: imageLinks.length)
  //               .show())
  //           : () {},
  //       child: getImagePreviewFromNet());
  // }

  // Need to do the same as above, but with PhotoViewGallery
              onTap: () => imageLinks.isNotEmpty
                ? Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(),
                      body: PhotoViewGallery.builder(
                        itemCount: imageLinks.length,
                        builder: (context, index) {
                          return PhotoViewGalleryPageOptions(
                            imageProvider: NetworkImage(imageLinks[index]),
                            initialScale: PhotoViewComputedScale.contained,
                            minScale: PhotoViewComputedScale.contained * 0.8,
                            maxScale: PhotoViewComputedScale.covered * 2,
                          );
                        },
                        // Get the index of the image that was tapped
                        // by finding the index of this ImagePreview in the list of previews
                        // and then adding 1 to skip the first null value in imageLinks.
                      ),
                    ),
                  ),
                )
                : () {},
            child: getImagePreviewFromNet(),
            );
        }

        Image getImagePreviewFromNet() {
          return Image.network(
            file.thumbnail!,
            height: 140,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                  height: 140, width: 140, child: Text("error"));
            },
          );
        }

        Image getImageFromNet(int index) {
          return Image.network(imageLinks[index]);
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
