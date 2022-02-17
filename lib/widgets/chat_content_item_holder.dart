import 'package:firebase_chat_app/dialogs/chat_content_item_dialog.dart';
import 'package:firebase_chat_app/helpers/datetime_helper.dart';
import 'package:firebase_chat_app/models/chat_content_item_type.dart';
import 'package:firebase_chat_app/models/cloud_chat_content_item.dart';
import 'package:firebase_chat_app/models/upload_chat_content_item.dart';
import 'package:firebase_chat_app/chat_provider.dart';
import 'package:firebase_chat_app/screens/chat_media_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'chat_content_item_widget.dart';

///Holder to display the time a message was sent and who it was sent by.
///This widget also controls whether the message has been uploaded to the cloud
///as well as if the message has been read by the recipient or not.
///The widget also controls navigation of videos and images messages to a different screen
///and controls the action of the user being able to unsend messages they have sent.
///Images and videos displayed while they are in the process of uploading.

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
    final ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);
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
            onLongPress: (chatContentItem.isRecipient ||
                    (chatContentItem.runtimeType == UploadChatContentItem &&
                        chatContentItem
                            .isSending)) //can not unsend when image or video is being uploaded or when message is sent by recipient
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
                                  id: id, chatContentItem: chatContentItem),
                            ));
                  },
            onTap: (chatContentItem.chatContentItemType ==
                        ChatContentItemType.TEXT ||
                    (chatContentItem.runtimeType == UploadChatContentItem &&
                        chatContentItem
                            .isSending)) //can not navigate when image or video being uploaded.
                ? null
                : () async {
                    chatProvider.updateReadReceipts();
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
                  (chatContentItem.onCloud == null ||
                      chatContentItem
                          .onCloud)) // time only displayed when message has reached the Firebase Firestore.
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
                  chatContentItem.onCloud !=
                      null) //read receipts and instance of upload checks are only display if messages sent by user.
                Icon(
                  chatContentItem.onCloud
                      ? FontAwesomeIcons.checkDouble
                      : FontAwesomeIcons.check,
                  color: chatContentItem.read && chatContentItem.onCloud
                      ? Colors.blue
                      : Colors.black,
                  size: 10,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
