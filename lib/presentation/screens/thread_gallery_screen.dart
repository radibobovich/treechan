import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:treechan/config/themes.dart';
import 'package:treechan/di/injection.dart';
import 'package:treechan/domain/models/core/core_models.dart';
import 'package:treechan/domain/models/tab.dart';
import 'package:treechan/domain/services/media_download_service.dart';
import 'package:treechan/presentation/widgets/shared/media_preview_widget.dart';

/// A screen with all the images and videos in the thread.
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

class _ThreadGalleryScreenState extends State<ThreadGalleryScreen> {
  List<Widget> media = [];
  Set<Widget> selected = {};
  late int crossAxisCount;
  Orientation? prevOrientation;

  void prepareGrid(Orientation orientation) {
    crossAxisCount = orientation == Orientation.portrait
        ? widget.portraitItemsPerRow
        : widget.landscapeItemsPerRow;
    final double displayWidth = MediaQuery.of(context).size.width;
    final double itemDimension =
        displayWidth / crossAxisCount - widget.spacing * (crossAxisCount - 1);

    /// Complete links to full URL's
    final fixedFiles = fixLinks(widget.files, widget.currentTab.imageboard);
    selected.clear();
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
          title: selected.isEmpty
              ? const Text('Галерея')
              : Text('Выбрано: ${selected.length}'),
          actions: [
            selected.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      final downloader = getIt<MediaDownloadService>();
                      downloader.downloadMultiple(
                          selected
                              .map((e) => (e as MediaItemPreview).file)
                              .toList(),
                          imageboard: widget.currentTab.imageboard);
                    },
                    icon: const Icon(Icons.download))
                : const SizedBox.shrink()
          ],
        ),
        body: OrientationBuilder(builder: (context, orientation) {
          if (prevOrientation != orientation) {
            prepareGrid(orientation);
            prevOrientation = orientation;
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: widget.spacing,
              crossAxisSpacing: widget.spacing,
            ),
            itemCount: media.length,
            itemBuilder: (context, index) {
              return InkWell(onTap: () {
                if (selected.isEmpty) return;
                setState(() {
                  if (selected.contains(media[index])) {
                    selected.remove(media[index]);
                  } else {
                    selected.add(media[index]);
                  }
                });
              }, onLongPress: () {
                setState(() {
                  if (selected.isEmpty) {
                    selected.add(media[index]);
                  }
                });
              }, child: Builder(builder: (context) {
                if (selected.contains(media[index])) {
                  // return const ColoredBox(color: Colors.red);
                  return Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: context.theme.secondaryHeaderColor,
                              width: 2)),
                      child: IgnorePointer(child: media[index]));
                }
                return IgnorePointer(
                    ignoring: selected.isNotEmpty, child: media[index]);
              }));
            },
          );
        }),
      ),
    );
  }
}
