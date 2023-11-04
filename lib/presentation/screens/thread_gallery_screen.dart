import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/domain/models/tab.dart';
import 'package:treechan/presentation/widgets/shared/media_preview_widget.dart';

class ThreadGalleryScreen extends StatefulWidget {
  const ThreadGalleryScreen({
    super.key,
    required this.files,
    required this.currentTab,
    required this.spacing,
    required this.portraitItemsPerRow,
    required this.landscapeItemsPerRow,
  });
  final List<File> files;
  final ThreadTab currentTab;
  final double spacing;
  final int portraitItemsPerRow;
  final int landscapeItemsPerRow;
  @override
  State<ThreadGalleryScreen> createState() => _ThreadGalleryScreenState();
}

class _ThreadGalleryScreenState extends State<ThreadGalleryScreen>
    with WidgetsBindingObserver {
  List<Widget> media = [];
  late int crossAxisCount;
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void prepareGrid(Orientation orientation) {
    crossAxisCount = orientation == Orientation.portrait
        ? widget.portraitItemsPerRow
        : widget.landscapeItemsPerRow;
    final double displayWidth = MediaQuery.of(context).size.width;
    final double itemDimension =
        displayWidth / crossAxisCount - widget.spacing * (crossAxisCount - 1);
    debugPrint(itemDimension.toString());

    /// Complete links to full URL's
    final fixedFiles = fixLinks(widget.files, widget.currentTab.imageboard);

    media = getMediaItems(fixedFiles, widget.currentTab.imageboard, context,
        height: itemDimension, squareShaped: true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Галерея'),
        ),
        body: OrientationBuilder(builder: (context, orientation) {
          prepareGrid(orientation);
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: widget.spacing,
              crossAxisSpacing: widget.spacing,
            ),
            itemCount: media.length,
            itemBuilder: (context, index) {
              return media[index];
            },
          );
        }),
      ),
    );
  }
}
