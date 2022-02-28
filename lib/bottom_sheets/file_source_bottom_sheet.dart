import 'dart:io';
import 'package:firebase_chat_app/models/file_response.dart';
import 'package:flutter/material.dart';

///bottom sheet to allow user to choose the media type they would like to send.

class FileSourceBottomSheet extends StatelessWidget {
  final Future<FileResponse?> Function() importImage;
  final Future<FileResponse?> Function() importVideo;

  FileSourceBottomSheet({required this.importImage, required this.importVideo});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Wrap(
        children: [
          ListTile(
            leading: Icon(
              Icons.image,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text('Image'),
            onTap: () async {
              final FileResponse? pickedImage = await importImage();
              Navigator.of(context).pop(pickedImage);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.videocam,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text('Video'),
            onTap: () async {
              final FileResponse? pickedImage = await importVideo();
              Navigator.of(context).pop(pickedImage);
            },
          ),
        ],
      ),
    );
  }
}
