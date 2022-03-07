import 'package:firebase_chat_app/providers/chat_provider.dart';
import 'package:firebase_chat_app/dialogs/chat_content_item_dialog.dart';
import 'package:firebase_chat_app/models/chat_content_item_type.dart';
import 'package:firebase_chat_app/models/chat_content_item_view_models/cloud_chat_content_item_view.dart';
import 'package:firebase_chat_app/screens/chat_media_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///Wrapper to handle tap events of chat content items.
class ChatContentItemEventHandler extends StatelessWidget {
  final Widget child;
  final CloudChatContentItemView
      cloudChatContentItemView; //only available for messages that have been uploaded to cloud.

  ChatContentItemEventHandler(
      {required this.cloudChatContentItemView, required this.child});

  @override
  Widget build(BuildContext context) {
    final ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);
    return GestureDetector(
        onLongPress: (cloudChatContentItemView
                .isRecipient) //can not unsend message sent by recipient
            ? null
            : () async {
                chatProvider
                    .updateReadReceipts(); //updates read receipts of all messages not read
                showDialog(
                    context: context,
                    builder: (context) =>
                        ChangeNotifierProvider<ChatProvider>.value(
                          value: chatProvider,
                          child: ChatContentItemDialog(
                            cloudChatContentItemView: cloudChatContentItemView,
                          ),
                        ));
              },
        onTap: (cloudChatContentItemView.chatContentItemType ==
                ChatContentItemType.TEXT) //can not navigate a text message.
            ? null
            : () async {
                chatProvider.updateReadReceipts();
                var mediaURL;
                if (cloudChatContentItemView.chatContentItemType ==
                    ChatContentItemType.IMAGE)
                  mediaURL = cloudChatContentItemView.content; //image URL
                else if (cloudChatContentItemView.chatContentItemType ==
                    ChatContentItemType.VIDEO)
                  mediaURL = cloudChatContentItemView.content[0]; //video URL
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatMediaPreviewScreen(
                        chatContentItemType:
                            cloudChatContentItemView.chatContentItemType,
                        mediaPath: mediaURL),
                  ),
                );
              },
        child: child);
  }
}
