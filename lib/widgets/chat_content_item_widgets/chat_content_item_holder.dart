import 'package:firebase_chat_app/models/chat_content_item_view_models/chat_content_item_view.dart';
import 'package:firebase_chat_app/models/chat_content_item_view_models/cloud_chat_content_item_view.dart';
import 'package:firebase_chat_app/models/chat_content_item_view_models/upload_chat_content_item_view.dart';
import 'package:firebase_chat_app/widgets/chat_content_item_widgets/cloud_chat_content_item_widgets/cloud_chat_content_item_widget.dart';
import 'package:firebase_chat_app/widgets/chat_content_item_widgets/upload_chat_content_item_widgets/upload_chat_media_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';
import 'chat_content_item_date_heading.dart';

///Holder for all ChatContentItemWidgets, it can display the name of the user who sent the message.
class ChatContentItemHolder extends StatelessWidget {
  final ChatContentItemView chatContentItemView;

  ChatContentItemHolder({required this.chatContentItemView})
      : super(key: ValueKey(chatContentItemView.id));

  ///function builds Cloud and Upload Chat Content Items dependant on ChatContentItemView data type.
  Widget _buildChatContentItemWidget() {
    if (chatContentItemView.runtimeType == CloudChatContentItemView) {
      return CloudChatContentItemWidget(
          cloudChatContentItemView:
              chatContentItemView as CloudChatContentItemView);
    } else {
      return UploadChatContentItemWidget(
          uploadChatContentItemView:
              chatContentItemView as UploadChatContentItemView);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);
    final Widget widget = Padding(
      padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
      child: Column(
        crossAxisAlignment: chatContentItemView.isRecipient
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          if (chatContentItemView.showName) //may show name of sender.
            Container(
              margin: EdgeInsets.only(bottom: 3),
              child: Text(
                chatContentItemView.chatContentItem.isRecipient
                    ? chatProvider.recipientName
                    : chatProvider.myName,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      fontSize: 10,
                    ),
              ),
            ),
          _buildChatContentItemWidget(),
        ],
      ),
    );
    if (chatContentItemView.showDateHeading)
      return Column(
        children: [
          ChatContentItemDateHeading(
            createdAt: chatContentItemView.createdAt,
          ),
          widget,
        ],
      );
    else
      return widget;
  }
}
