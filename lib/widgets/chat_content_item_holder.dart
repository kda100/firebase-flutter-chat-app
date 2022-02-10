import 'package:firebase_chat_app/helpers/datetime_helper.dart';
import 'package:firebase_chat_app/models/chat_content_item_type.dart';
import 'package:firebase_chat_app/models/cloud_chat_content_item.dart';
import 'package:firebase_chat_app/models/upload_chat_content_item.dart';
import 'package:firebase_chat_app/providers/chat_provider.dart';
import 'package:firebase_chat_app/screens/chat_media_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'chat_content_item_widget.dart';

class ChatContentItemHolder extends StatelessWidget {
  final String id;
  final bool showName;
  final chatContentItem;

  ChatContentItemHolder({
    required this.id,
    required this.showName,
    required this.chatContentItem,
  }) : super(key: ValueKey(id));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
      child: Column(
        crossAxisAlignment: chatContentItem.isRecipient
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          if (showName)
            Container(
              margin: EdgeInsets.only(bottom: 3),
              child: Text(
                chatContentItem.sentBy,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      fontSize: 10,
                    ),
              ),
            ),
          GestureDetector(
            onTap: (chatContentItem.chatContentItemType ==
                        ChatContentItemType.TEXT ||
                    (chatContentItem.runtimeType == UploadChatContentItem &&
                        chatContentItem.isSending))
                ? null
                : () async {
                    Provider.of<ChatProvider>(
                      context,
                      listen: false,
                    ).updateReadReceipts();
                    var mediaPath;
                    if (chatContentItem.chatContentItemType ==
                        ChatContentItemType.IMAGE)
                      mediaPath = chatContentItem.content;
                    else if (chatContentItem.chatContentItemType ==
                        ChatContentItemType.VIDEO)
                      mediaPath = chatContentItem.content[0];
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatMediaPreviewScreen(
                          chatContentItemType:
                              chatContentItem.chatContentItemType,
                          mediaPath: mediaPath,
                          isStorage: chatContentItem.runtimeType ==
                              CloudChatContentItem,
                        ),
                      ),
                    );
                  },
            child: ChatContentItemWidget(
              key: key,
              id: id,
              chatContentItem: chatContentItem,
            ),
          ),
          Row(
            mainAxisAlignment: chatContentItem.isRecipient
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              if (chatContentItem.runtimeType == CloudChatContentItem &&
                  (chatContentItem.onCloud == null || chatContentItem.onCloud))
                Container(
                  margin: EdgeInsets.only(top: 3),
                  child: Text(
                    DateTimeHelper.formatDateTimeToTimeString(
                        chatContentItem.createdAt),
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(
                          fontSize: 11,
                        ),
                  ),
                ),
              SizedBox(
                width: 2,
              ),
              if (chatContentItem.runtimeType == CloudChatContentItem &&
                  !chatContentItem.isRecipient &&
                  chatContentItem.onCloud != null)
                Icon(
                  chatContentItem.onCloud
                      ? FontAwesomeIcons.checkDouble
                      : FontAwesomeIcons.check,
                  color: chatContentItem.read ? Colors.blue : Colors.black,
                  size: 10,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
