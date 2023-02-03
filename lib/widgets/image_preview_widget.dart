import 'package:flutter/material.dart';
import 'package:treechan/models/board_json.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';

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
  //List<Widget> images = List<Widget>.filled(8, const SizedBox.shrink());
  List<Widget> images = List<Widget>.empty(growable: true);
  List<String> imageLinks = List<String>.empty(growable: true);
  var supportedFormats = [1, 2, 4];
  for (var file in files) {
    if (supportedFormats.contains(file.type)) {
      imageLinks.add("https://2ch.hk${file.path ?? ""}");
    }
  }
  for (var file in files) {
    if (supportedFormats.contains(file.type)) {
      images.add(
          ImagePreview(imageLinks: imageLinks, file: file, context: context));
    }
  }
  // for (int i = 0; i < files.length; i++) {
  //   if (files[i].thumbnail != null) {
  //     images[i] =
  //         Image.network(files[i].thumbnail!, height: 140, fit: BoxFit.contain);
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
    return GestureDetector(
        onTap: () => imageLinks.isNotEmpty
            ? (SwipeImageGallery(
                    context: context,
                    itemBuilder: (context, index) {
                      return getImageFromNet(index);
                    },
                    itemCount: imageLinks.length)
                .show())
            : () {},
        child: getImagePreviewFromNet());
  }

  // TODO: fix bug when image is 404, for example Books - first thread - link to Ink thread - scroll down
  Image getImagePreviewFromNet() {
    return Image.network(
      file.thumbnail!,
      height: 140,
      fit: BoxFit.contain,
    );
    // return FutureBuilder<ImageProvider>(
    //   future: tryPrecache(context,
    //       provider: NetworkImage(file.thumbnail!),
    //       fallback:
    //           const NetworkImage("https://2ch.hk/static/img/nf/404_3.jpg")),
    //   builder: (context, provider) => !provider.hasData
    //       ? const CircularProgressIndicator()
    //       : provider.hasError
    //           ? const Icon(Icons.error)
    //           : Image(image: provider.data!),
    // );
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
