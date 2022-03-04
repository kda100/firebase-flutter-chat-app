import 'package:firebase_chat_app/constants/color_palette.dart';
import 'package:firebase_chat_app/widgets/image_preview_widget.dart';
import 'package:firebase_chat_app/widgets/video_preview_widget.dart';
import 'package:firebase_chat_app/constants/strings.dart';
import '../models/chat_content_item_type.dart';
import 'package:flutter/material.dart';

///screen to present video and images to user.

class ChatMediaPreviewScreen extends StatelessWidget {
  final ChatContentItemType chatContentItemType;
  final String mediaPath;

  ChatMediaPreviewScreen({
    required this.chatContentItemType,
    required this.mediaPath,
  });

  Widget _buildMediaPreviewWidget() {
    if (chatContentItemType == ChatContentItemType.IMAGE) {
      return ImagePreviewWidget(
        imagePath: mediaPath,
      );
    } else if (chatContentItemType == ChatContentItemType.VIDEO) {
      return VideoPreviewWidget(
        videoPath: mediaPath,
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
      backgroundColor: ColorPalette.secondaryBackgroundColor,
      body: _buildMediaPreviewWidget(),
    );
  }
}
