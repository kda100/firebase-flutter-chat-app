import 'package:firebase_chat_app/models/chat_content_item_view_models/cloud_chat_content_item_view.dart';
import 'package:firebase_chat_app/widgets/chat_content_item_widgets/chat_content_item_event_handler.dart';
import 'package:flutter/material.dart';

///Widget used to display text messages (ChatContentItemType == TEXT).
///The widget shows the content of the message.
///The widget has different designs depending on if it was sent by the user or the recipient.

class ChatTextItemWidget extends StatelessWidget {
  final CloudChatContentItemView cloudChatContentItemView;

  ChatTextItemWidget({required this.cloudChatContentItemView});

  @override
  Widget build(BuildContext context) {
    final Widget chatTextItemWidget = Container(
      decoration: BoxDecoration(
        color: cloudChatContentItemView.isRecipient //different colours.
            ? Theme.of(context).primaryColorLight
            : Theme.of(context).primaryColorDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomLeft: cloudChatContentItemView.isRecipient //different design
              ? Radius.circular(0)
              : Radius.circular(12),
          bottomRight: cloudChatContentItemView.isRecipient
              ? Radius.circular(12)
              : Radius.circular(0),
        ),
      ),
      constraints: BoxConstraints(
        maxWidth: 200,
      ),
      padding: EdgeInsets.all(10),
      child: Text(cloudChatContentItemView.content,
          softWrap: true,
          style: cloudChatContentItemView.isRecipient
              ? Theme.of(context).textTheme.bodyText1 //different text themes
              : Theme.of(context).textTheme.bodyText2),
    );
    if (!cloudChatContentItemView.isRecipient) {
      //user has ability to unsend messages they have sent.
      return ChatContentItemEventHandler(
        cloudChatContentItemView: cloudChatContentItemView,
        child: chatTextItemWidget,
      );
    } else {
      return chatTextItemWidget;
    }
  }
}
