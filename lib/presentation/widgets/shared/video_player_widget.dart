import 'package:flutter/material.dart';
import 'package:treechan/domain/models/core/core_models.dart';

import 'package:video_player/video_player.dart';
import "package:flick_video_player/flick_video_player.dart";

//import 'package:flick_video_player/flick_video_player.dart';
class VideoPlayer extends StatefulWidget {
  const VideoPlayer({super.key, required this.file});
  final File file;
  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late FlickManager flickManager;
  late VideoPlayerController controller;
  // VideoPlayerController.network("https://2ch.hk${widget.file.path!})");
  @override
  void initState() {
    super.initState();
    String url = widget.file.path.contains("http")
        ? widget.file.path
        : "https://2ch.hk${widget.file.path}";
    controller = VideoPlayerController.networkUrl(Uri.tryParse(url)!);
    flickManager = FlickManager(
      videoPlayerController: controller,
    );
  }

  @override
  void dispose() async {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
          // aspectRatio: controller.value.aspectRatio,
          aspectRatio: (widget.file.width) / (widget.file.height),
          child: FlickVideoPlayer(
            flickManager: flickManager,
          )),
    );
  }
}
