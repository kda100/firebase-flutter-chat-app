import 'package:firebase_chat_app/constants/text_styles.dart';
import 'package:firebase_chat_app/dialogs/actionable_alert_dialog.dart';
import 'package:firebase_chat_app/models/chat_item_type.dart';
import 'package:firebase_chat_app/models/chat_item_view_models/cloud_chat_item_view.dart';
import 'package:firebase_chat_app/models/platform_widget_models.dart';
import 'package:firebase_chat_app/providers/chat_provider.dart';
import 'package:firebase_chat_app/dialogs/chat_content_item_dialog.dart';
import 'package:firebase_chat_app/screens/chat_media_preview_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

///Wrapper to handle tap events of chat content items.
class ChatItemEventHandler extends PlatformStatelessWidget<Widget, Widget> {
  final Widget child;
  final CloudChatItemView
      cloudChatItemView; //only available for messages that have been uploaded to cloud.

  ChatItemEventHandler({required this.cloudChatItemView, required this.child});

  GestureDetector _buildGestureDetector(BuildContext context) {
    final ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);
    return GestureDetector(
      onLongPress: (cloudChatItemView.isRecipient ||
              Platform.isIOS) //can not unsend message sent by recipient
          ? null
          : () async {
              chatProvider
                  .updateReadReceipts(); //updates read receipts of all messages not read
              showDialog(
                context: context,
                builder: (context) => ChatItemDialog(
                  onUnsend: () {
                    _onUnsend(
                      context,
                    );
                  },
                ),
              );
            },
      onTap: (cloudChatItemView.chatItemType ==
              ChatItemType.TEXT) //can not navigate a text message.
          ? null
          : () async {
              chatProvider.updateReadReceipts();
              var mediaURL;
              if (cloudChatItemView.chatItemType == ChatItemType.IMAGE)
                mediaURL = cloudChatItemView.content; //image URL
              else if (cloudChatItemView.chatItemType == ChatItemType.VIDEO)
                mediaURL = cloudChatItemView.content[0]; //video URL
              await Navigator.of(context).push(
                Platform.isIOS
                    ? CupertinoPageRoute(
                        builder: (context) => ChatMediaPreviewScreen(
                            chatItemType: cloudChatItemView.chatItemType,
                            mediaPath: mediaURL),
                      )
                    : MaterialPageRoute(
                        builder: (context) => ChatMediaPreviewScreen(
                            chatItemType: cloudChatItemView.chatItemType,
                            mediaPath: mediaURL),
                      ),
              );
            },
      child: child,
    );
  }

  void _onUnsend(BuildContext context) async {
    final ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);
    final bool? result = await showCupertinoDialog(
      context: context,
      builder: (context) {
        return ActionableAlertDialog(
          title: "Are you sure you want to unsend?",
        );
      },
    );
    if (result != null && result) {
      chatProvider.unSendChatItem(id: cloudChatItemView.id);
    }
  }

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    if (cloudChatItemView.isRecipient) {
      return _buildGestureDetector(context);
    } else {
      return CupertinoContextMenu(
        actions: [
          CupertinoContextMenuAction(
            child: Text(
              "Unsend?",
              style: TextStyles.popupMenuLabelTextStyle,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _onUnsend(context);
            },
          ),
        ],
        child: _buildGestureDetector(context),
      );
    }
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return _buildGestureDetector(context);
  }
}
