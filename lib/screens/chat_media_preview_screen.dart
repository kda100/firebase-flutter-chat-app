import 'package:firebase_chat_app/widgets/image_preview_widget.dart';
import 'package:firebase_chat_app/widgets/video_preview_widget.dart';
import 'package:firebase_chat_app/constants/strings.dart';
import 'package:firebase_chat_app/models/chat_content_item_type.dart';
import 'package:flutter/material.dart';

///screen to present video and images to user.

class ChatMediaPreviewScreen extends StatelessWidget {
  final ChatContentItemType chatContentItemType;
  final String mediaPath;
  final bool isStorage; //whether image in on the cloud or on the users device.

  ChatMediaPreviewScreen({
    required this.chatContentItemType,
    required this.mediaPath,
    required this.isStorage,
  });

  Widget _buildMediaPreviewWidget() {
    if (chatContentItemType == ChatContentItemType.IMAGE) {
      return ImagePreviewWidget(
        imagePath: mediaPath,
        isStorage: isStorage,
      );
    } else if (chatContentItemType == ChatContentItemType.VIDEO) {
      return VideoPreviewWidget(
        videoPath: mediaPath,
        isStorage: isStorage,
      );
    }
    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.appName),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: _buildMediaPreviewWidget(),
      floatingActionButton:
          isStorage //can't send a image or video that has already been uploading to cloud.
              ? null
              : FloatingActionButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Icon(Icons.send),
                ),
    );
  }
}
