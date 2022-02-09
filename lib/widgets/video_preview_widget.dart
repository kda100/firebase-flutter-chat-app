import 'package:firebase_chat_app/helpers/duration_helper.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoPreviewWidget extends StatefulWidget {
  final String videoPath;
  final bool isStorage;

  VideoPreviewWidget({required this.videoPath, required this.isStorage});

  @override
  _VideoPreviewWidgetState createState() =>
      _VideoPreviewWidgetState(videoPath, isStorage);
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  final VideoPlayerController _videoPlayerController;
  final String videoPath;
  final bool isStorage;
  double doubleVideoDuration = 0;
  double doubleCurrentDuration = 0;
  String stringVideoDuration = "";
  String stringCurrentDuration = "";
  _VideoPreviewWidgetState(this.videoPath, this.isStorage)
      : _videoPlayerController = isStorage
            ? VideoPlayerController.network(videoPath)
            : VideoPlayerController.file(
                File(videoPath),
              );

  @override
  void initState() {
    super.initState();
    _videoPlayerController.initialize().then((_) {
      setState(() {
        doubleVideoDuration =
            _videoPlayerController.value.duration.inMilliseconds.toDouble();
        stringVideoDuration =
            DurationHelper.videoPlayerTimerString(doubleVideoDuration);
      });
    });

    _videoPlayerController.addListener(() {
      setState(() {
        doubleCurrentDuration =
            _videoPlayerController.value.position.inMilliseconds.toDouble();
        stringCurrentDuration =
            DurationHelper.videoPlayerTimerString(doubleCurrentDuration);
      });
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
            constraints: BoxConstraints(maxHeight: 400),
            child: _videoPlayerController.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(_videoPlayerController),
                  )
                : Container(
                    child: CircularProgressIndicator(),
                  ),
          ),
          if (_videoPlayerController.value.isInitialized)
            Slider(
              value: doubleCurrentDuration,
              max: doubleVideoDuration,
              onChanged: (value) {
                _videoPlayerController.seekTo(
                  Duration(
                    milliseconds: value.toInt(),
                  ),
                );
              },
            ),
          if (_videoPlayerController.value.isInitialized)
            Container(
              margin: EdgeInsets.only(right: 8),
              alignment: Alignment.centerRight,
              child: Text(
                "$stringCurrentDuration" + "/" + "$stringVideoDuration",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          if (_videoPlayerController.value.isInitialized)
            Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: IconButton(
                    color: Colors.white,
                    icon: Icon(_videoPlayerController.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow),
                    onPressed: () {
                      setState(() {
                        if (doubleCurrentDuration == doubleVideoDuration) {
                          _videoPlayerController.initialize();
                        }
                        _videoPlayerController.value.isPlaying
                            ? _videoPlayerController.pause()
                            : _videoPlayerController.play();
                      });
                    }))
        ],
      ),
    );
  }
}
