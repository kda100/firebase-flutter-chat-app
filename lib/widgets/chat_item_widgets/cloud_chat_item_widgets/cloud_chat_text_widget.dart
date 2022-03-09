import 'package:firebase_chat_app/models/chat_item_view_models/cloud_chat_item_view.dart';
import 'package:flutter/material.dart';

import '../chat_item_event_handler.dart';

///Widget used to display text messages (ChatContentItemType == TEXT).
///The widget shows the content of the message.
///The widget has different designs depending on if it was sent by the user or the recipient.

class CloudChatTextWidget extends StatelessWidget {
  final CloudChatItemView cloudChatItemView;

  CloudChatTextWidget({required this.cloudChatItemView});

  @override
  Widget build(BuildContext context) {
    final Widget chatTextItemWidget = Container(
      decoration: BoxDecoration(
        color: cloudChatItemView.isRecipient //different colours.
            ? Theme.of(context).primaryColorLight
            : Theme.of(context).primaryColorDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomLeft: cloudChatItemView.isRecipient //different design
              ? Radius.circular(0)
              : Radius.circular(12),
          bottomRight: cloudChatItemView.isRecipient
              ? Radius.circular(12)
              : Radius.circular(0),
        ),
      ),
      constraints: BoxConstraints(
        maxWidth: 200,
      ),
      padding: EdgeInsets.all(10),
      child: Text(cloudChatItemView.content,
          softWrap: true,
          style: cloudChatItemView.isRecipient
              ? Theme.of(context).textTheme.bodyText1 //different text themes
              : Theme.of(context).textTheme.bodyText2),
    );
    if (!cloudChatItemView.isRecipient) {
      //user has ability to unsend messages they have sent.
      return ChatItemEventHandler(
        cloudChatItemView: cloudChatItemView,
        child: chatTextItemWidget,
      );
    } else {
      return chatTextItemWidget;
    }
  }
}
