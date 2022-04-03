import 'dart:async';
import 'package:firebase_chat_app/utilities/ui_util.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../../constants/color_palette.dart';

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
        print(progress);
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
    final UIUtil uiUtil = UIUtil(context);
    return AnimatedContainer(
      color: ColorPalette.primaryColor,
      duration: Duration(milliseconds: 100),
      height: 4,
      width: progress * uiUtil.maxChatItemWidth,
    );
  }
}
