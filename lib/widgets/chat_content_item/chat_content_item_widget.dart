import 'package:firebase_chat_app/widgets/chat_content_item/cloud_chat_media_item_widget.dart';
import 'package:firebase_chat_app/widgets/chat_content_item/upload_chat_media_item_widget.dart';
import 'package:firebase_chat_app/models/chat_content_item_type.dart';
import 'package:firebase_chat_app/models/cloud_chat_content_item.dart';
import 'package:firebase_chat_app/models/upload_chat_content_item.dart';
import 'package:flutter/material.dart';
import 'chat_text_item_widget.dart';

///Widget used to control the type of widget displayed by the chat screen based on the
///the ChatContentItemType attribute that is given by the chat content item object passed in.

class ChatContentItemWidget extends StatelessWidget {
  final String id;
  final chatContentItem;

  ChatContentItemWidget({
    required Key? key,
    required this.chatContentItem,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (chatContentItem.chatContentItemType == ChatContentItemType.TEXT) {
      //for all text messages
      return ChatTextItemWidget(chatContentItem: chatContentItem);
    } else {
      //ChatContentItemType.VIDEO || ChatContentItemType.IMAGE
      Widget widget = SizedBox();
      if (chatContentItem.runtimeType == UploadChatContentItem) {
        //image or video being uploaded to Firebase from device
        widget = UploadChatMediaItemWidget(
          id: id,
          uploadChatContentItem: chatContentItem,
        );
      } else if (chatContentItem.runtimeType == CloudChatContentItem) {
        //displays image or video thumbnail that is stored on Firebase
        widget =
            CloudChatMediaItemWidget(cloudChatContentItem: chatContentItem);
      }
      return ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 150,
          maxWidth: 200,
          minWidth: 200,
        ),
        child: widget,
      );
    }
  }
}
