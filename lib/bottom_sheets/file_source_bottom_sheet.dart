import 'package:flutter/material.dart';
import 'dart:io';

class FileTypeBottomSheet {
  static Widget buildMediaFileTypeBottomSheet({
    required BuildContext context,
    required Future<File?> Function() importImage,
    required Future<File?> Function() importVideo,
  }) {
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
              final File? pickedImage = await importImage();
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
              final File? pickedImage = await importVideo();
              Navigator.of(context).pop(pickedImage);
            },
          ),
        ],
      ),
    );
  }
}
