import 'package:firebase_chat_app/models/cloud_chat_content_item.dart';
import 'package:flutter/material.dart';

///Widget used to display text messages (ChatContentItemType == TEXT).
///The widget shows the content of the message.
///The widget has different designs depending on if it was sent by the user or the recipient.

class ChatTextItemWidget extends StatelessWidget {
  final CloudChatContentItem chatContentItem;

  ChatTextItemWidget({required this.chatContentItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: chatContentItem.isRecipient //different colours.
            ? Theme.of(context).primaryColorLight
            : Theme.of(context).primaryColorDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomLeft: chatContentItem.isRecipient //different design
              ? Radius.circular(0)
              : Radius.circular(12),
          bottomRight: chatContentItem.isRecipient
              ? Radius.circular(12)
              : Radius.circular(0),
        ),
      ),
      constraints: BoxConstraints(
        maxWidth: 200,
      ),
      padding: EdgeInsets.all(10),
      child: Text(chatContentItem.content,
          softWrap: true,
          style: chatContentItem.isRecipient
              ? Theme.of(context).textTheme.bodyText1 //different text themes
              : Theme.of(context).textTheme.bodyText2),
    );
  }
}
