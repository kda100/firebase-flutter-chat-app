import 'package:firebase_chat_app/constants/color_palette.dart';
import 'package:firebase_chat_app/models/chat_item_type.dart';
import 'package:firebase_chat_app/models/platform_widget_models.dart';
import 'package:firebase_chat_app/screens/custom_cupertino_back_button.dart';
import 'package:firebase_chat_app/widgets/image_preview_widget.dart';
import 'package:firebase_chat_app/widgets/video_preview_widget.dart';
import 'package:firebase_chat_app/constants/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///screen to present video and images to user.

class ChatMediaPreviewScreen
    extends PlatformStatelessWidget<CupertinoPageScaffold, Scaffold> {
  final ChatItemType chatItemType;
  final String mediaPath;

  ChatMediaPreviewScreen({
    required this.chatItemType,
    required this.mediaPath,
  });

  final title = Text(Strings.appName);

  Widget _buildMediaPreviewWidget() {
    Widget widget = SizedBox();
    if (chatItemType == ChatItemType.IMAGE) {
      widget = ImagePreviewWidget(
        imagePath: mediaPath,
      );
    } else if (chatItemType == ChatItemType.VIDEO) {
      widget = VideoPreviewWidget(
        videoPath: mediaPath,
      );
    }
    return Center(
      child: SingleChildScrollView(
        child: widget,
      ),
    );
  }

  @override
  CupertinoPageScaffold buildCupertinoWidget(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CustomCupertinoBackButton(),
        middle: title,
        padding: EdgeInsetsDirectional.zero,
      ),
      backgroundColor: ColorPalette.secondaryBackgroundColor,
      child: _buildMediaPreviewWidget(),
    );
  }

  @override
  Scaffold buildMaterialWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
      ),
      backgroundColor: ColorPalette.secondaryBackgroundColor,
      body: _buildMediaPreviewWidget(),
    );
  }
}
