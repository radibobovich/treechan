import 'dart:async';

import 'package:flutter/material.dart';

import '../domain/models/json/json.dart';

import 'package:video_player/video_player.dart';

class ClassicPlayer extends StatefulWidget {
  const ClassicPlayer({super.key, required this.file});
  final File file;

  @override
  State<ClassicPlayer> createState() => _ClassicPlayerState();
}

class _ClassicPlayerState extends State<ClassicPlayer> {
  late VideoPlayerController _controller;
  late bool _isPlaying;
  late Timer _hideControlsTimer;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      "https://2ch.hk${widget.file.path!}",
    )..initialize().then((_) {
        setState(() {});
      });
    _isPlaying = false;
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _showControls = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideControlsTimer.cancel();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = !_isPlaying;
      _showControls = true;
      _hideControlsTimer.cancel();
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        setState(() {
          _showControls = false;
        });
      });
    });
  }

  Widget _buildPlayPauseButton() {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black54,
        ),
        child: Icon(
          _isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildControls() {
    return _showControls
        ? Positioned.fill(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 40,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildPlayPauseButton(),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = true;
            _hideControlsTimer.cancel();
            _hideControlsTimer = Timer(const Duration(seconds: 3), () {
              setState(() {
                _showControls = false;
              });
            });
          });
        },
        child: Stack(
          children: [
            _controller.value.isInitialized
                ? Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : const SizedBox.shrink(),
            _buildControls(),
          ],
        ),
      ),
    );
  }
}
