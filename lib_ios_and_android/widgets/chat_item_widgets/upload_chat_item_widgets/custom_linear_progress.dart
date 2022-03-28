import 'dart:async';
import 'dart:io';
import 'package:firebase_chat_app/constants/sizes.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

///custom linear progress indicator for animating the upload progress of UploadChatContentItems;
class CustomLinearProgress extends StatefulWidget {
  final Stream<TaskSnapshot> taskSnapshotsEvents;

  CustomLinearProgress({required this.taskSnapshotsEvents});

  @override
  _CustomLinearProgressState createState() => _CustomLinearProgressState();
}

class _CustomLinearProgressState extends State<CustomLinearProgress> {
  late StreamSubscription<TaskSnapshot> uploadFileTaskStream;
  double progress = 0;

  @override
  void initState() {
    uploadFileTaskStream = widget.taskSnapshotsEvents.listen((taskSnapshot) {
      setState(() {
        progress = taskSnapshot.bytesTransferred.toDouble() /
            taskSnapshot.totalBytes.toDouble();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    uploadFileTaskStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      color: Platform.isIOS
          ? CupertinoTheme.of(context).primaryColor
          : Theme.of(context).colorScheme.primary,
      duration: Duration(milliseconds: 100),
      height: 4,
      width: progress * kMaxChatContentItemWidth,
    );
  }
}
