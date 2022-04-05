import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

///bottom sheet to allow user to choose the media type they would like to send.

class FileSourceBottomSheet extends StatelessWidget {
  FileSourceBottomSheet();

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
              Navigator.of(context).pop(FileType.image);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.videocam,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text('Video'),
            onTap: () async {
              Navigator.of(context).pop(FileType.video);
            },
          ),
        ],
      ),
    );
  }
}
