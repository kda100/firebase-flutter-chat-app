import 'package:firebase_chat_app/widgets/image_preview_widget.dart';
import 'package:firebase_chat_app/widgets/video_preview_widget.dart';
import 'package:firebase_chat_app/constants/strings.dart';
import 'package:firebase_chat_app/models/chat_content_item_type.dart';
import 'package:flutter/material.dart';

class ChatMediaPreviewScreen extends StatelessWidget {
  final ChatContentItemType chatContentItemType;
  final String mediaPath;
  final bool isStorage;

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
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(Strings.appName),
        ),
        backgroundColor: Colors.black,
        body: _buildMediaPreviewWidget(),
        floatingActionButton: isStorage
            ? null
            : FloatingActionButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Icon(Icons.send),
              ),
      ),
    );
  }
}
