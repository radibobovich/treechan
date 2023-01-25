import 'package:flutter/material.dart';
import 'package:treechan/board_json.dart';

class ImagesGroup extends StatelessWidget {
  const ImagesGroup({Key? key, required this.files}) : super(key: key);

  final List<File>? files;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _getImages(files),
        ),
      ),
    );
  }
}

List<Widget> _getImages(List<File>? files) {
  if (files == null) {
    // return empty image list
    return List<Widget>.filled(1, const SizedBox.shrink());
  }
  List<Widget> images = List<Widget>.filled(8, const SizedBox.shrink());
  for (int i = 0; i < files.length; i++) {
    if (files[i].thumbnail != null) {
      images[i] =
          Image.network(files[i].thumbnail!, height: 140, fit: BoxFit.contain);
    }
  }
  return images;
}
