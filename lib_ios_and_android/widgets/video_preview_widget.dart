import 'package:firebase_chat_app/widgets/placeholder_widgets.dart';
import 'package:firebase_chat_app/widgets/platform_icon_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

///widget for previewing and watching video messages from device or stored on the cloud

class VideoPreviewWidget extends StatefulWidget {
  final String videoPath;

  VideoPreviewWidget({required this.videoPath});

  @override
  _VideoPreviewWidgetState createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  late VideoPlayerController _videoPlayerController;
  double doubleVideoDuration = 0;
  double doubleCurrentDuration = 0;
  String stringVideoDuration = "";
  String stringCurrentDuration = "";

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.network(widget.videoPath);
    _videoPlayerController.initialize().then((_) {
      setState(() {
        //sets videoDuration and and string video duration once controller initialised
        doubleVideoDuration =
            _videoPlayerController.value.duration.inMilliseconds.toDouble();
        stringVideoDuration = videoPlayerTimerString(doubleVideoDuration);
      });
    });

    _videoPlayerController.addListener(() {
      //changes the currentDuration as video progresses.
      setState(() {
        doubleCurrentDuration =
            _videoPlayerController.value.position.inMilliseconds.toDouble();
        stringCurrentDuration = videoPlayerTimerString(doubleCurrentDuration);
      });
    });
    super.initState();
  }

  ///function for converting current duration of video to string value.
  ///so users can see position of video they are watching (2:37)
  String videoPlayerTimerString(double milliseconds) {
    int hoursInt = milliseconds ~/ 3600000; //hours remaining
    int minutesInt = (milliseconds ~/ 60000) - (hoursInt * 60); //mins remaining
    int secondsInt =
        (milliseconds ~/ 1000) - (minutesInt * 60); // secs remaining.

    String hoursString = hoursInt > 0
        ? hoursInt < 10
            ? "0$hoursInt:"
            : "$hoursInt:"
        : ""; //no hours then leave hours string empty.
    String minutesString = hoursInt > 0 && minutesInt < 10
        ? "0$minutesInt:"
        : "$minutesInt:"; // "01:05:57" or "2:37"
    String secondsString =
        secondsInt < 10 ? "0$secondsInt" : "$secondsInt"; //"5:07" or "5:19"

    return "$hoursString$minutesString$secondsString";
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Widget _buildSlider() {
    void onChanged(double value) {
      _videoPlayerController.seekTo(
        Duration(
          milliseconds: value.toInt(),
        ),
      );
    }

    if (Platform.isIOS) {
      return CupertinoSlider(
        //controls position of video
        value: doubleCurrentDuration,
        max: doubleVideoDuration,
        onChanged: onChanged,
        thumbColor: CupertinoTheme.of(context).primaryColor,
      );
    } else {
      return Slider(
        //controls position of video
        value: doubleCurrentDuration,
        max: doubleVideoDuration,
        onChanged: onChanged,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_videoPlayerController.value.isInitialized) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 10,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 400),
              child: _videoPlayerController.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoPlayerController.value.aspectRatio,
                      child: VideoPlayer(_videoPlayerController),
                    )
                  : Center(
                      //while video player is loading.
                      child: CircularProgressIndicator.adaptive(),
                    ),
            ),
            if (_videoPlayerController.value.isInitialized) _buildSlider(),
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
                  child: PlatformIconButton(
                    icon: Icon(
                      _videoPlayerController.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        if (doubleCurrentDuration == doubleVideoDuration) {
                          //resets video if video has ended.
                          _videoPlayerController.initialize();
                        }
                        _videoPlayerController.value.isPlaying
                            ? _videoPlayerController.pause()
                            : _videoPlayerController.play();
                      });
                    },
                  ))
          ],
        ),
      );
    } else if (_videoPlayerController.value.hasError) {
      return Center(
        child: BrokenImagePlaceHolderWidget(),
      );
    } else {
      return Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }
  }
}
