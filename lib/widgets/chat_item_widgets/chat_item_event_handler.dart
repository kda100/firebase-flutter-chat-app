import 'package:firebase_chat_app/models/chat_item_type.dart';
import 'package:firebase_chat_app/models/chat_item_view_models/cloud_chat_item_view.dart';
import 'package:firebase_chat_app/providers/chat_provider.dart';
import 'package:firebase_chat_app/dialogs/chat_content_item_dialog.dart';
import 'package:firebase_chat_app/screens/chat_media_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///Wrapper to handle tap events of chat content items.
class ChatItemEventHandler extends StatelessWidget {
  final Widget child;
  final CloudChatItemView
      cloudChatItemView; //only available for messages that have been uploaded to cloud.

  ChatItemEventHandler({required this.cloudChatItemView, required this.child});

  @override
  Widget build(BuildContext context) {
    final ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);
    return GestureDetector(
      onLongPress: (cloudChatItemView
              .isRecipient) //can not unsend message sent by recipient
          ? null
          : () async {
              chatProvider
                  .updateReadReceipts(); //updates read receipts of all messages not read
              showDialog(
                context: context,
                builder: (context) => ChatItemDialog(
                  cloudChatItemView: cloudChatItemView,
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
                MaterialPageRoute(
                  builder: (context) => ChatMediaPreviewScreen(
                      chatItemType: cloudChatItemView.chatItemType,
                      mediaPath: mediaURL),
                ),
              );
            },
      child: child,
    );
  }
}
