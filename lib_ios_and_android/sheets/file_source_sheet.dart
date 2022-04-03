import 'package:file_picker/file_picker.dart';
import 'package:firebase_chat_app/models/platform_widget_models.dart';
import 'package:firebase_chat_app/constants/text_styles.dart';
import 'package:firebase_chat_app/utilities/ui_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///bottom sheet to allow user to choose the media type they would like to send.

class FileSourceSheet
    extends PlatformStatelessWidget<CupertinoActionSheet, Widget> {
  onTap(BuildContext context, FileType? fileType) {
    Navigator.pop(context, fileType);
  }

  @override
  CupertinoActionSheet buildCupertinoWidget(BuildContext context) {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            onTap(context, FileType.image);
          },
          child: Text("Image", style: TextStyles.cupertinoSheetTextStyle),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            onTap(context, FileType.video);
          },
          child: Text(
            "Video",
            style: TextStyles.cupertinoSheetTextStyle,
          ),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () {
          onTap(context, null);
        },
        child: Text(
          "Cancel",
          style: TextStyles.cupertinoSheetTextStyle,
        ),
      ),
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
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
