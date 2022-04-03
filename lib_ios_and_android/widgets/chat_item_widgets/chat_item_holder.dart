import 'package:firebase_chat_app/models/chat_item_view_models/chat_item_view.dart';
import 'package:firebase_chat_app/models/chat_item_view_models/cloud_chat_item_view.dart';
import 'package:firebase_chat_app/models/chat_item_view_models/upload_chat_item_view.dart';
import 'package:firebase_chat_app/widgets/chat_item_widgets/upload_chat_item_widgets/upload_chat_image_and_video_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../utilities/text_styles.dart';
import '../../utilities/ui_util.dart';
import 'chat_item_date_heading.dart';
import 'cloud_chat_item_widgets/cloud_chat_item_widget.dart';

///Holder for all ChatContentItemWidgets, it can display the name of the user who sent the message.
class ChatItemHolder extends StatelessWidget {
  final ChatItemView chatItemView;

  ChatItemHolder({required this.chatItemView})
      : super(key: ValueKey(chatItemView.id));

  ///function builds Cloud and Upload Chat Content Items dependant on ChatContentItemView data type.
  Widget _buildChatItemWidget() {
    if (chatItemView.runtimeType == CloudChatItemView) {
      return CloudChatItemWidget(
          cloudChatItemView: chatItemView as CloudChatItemView);
    } else {
      return UploadChatImageAndVideoWidget(
          uploadChatItemView: chatItemView as UploadChatItemView);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
      child: Column(
        crossAxisAlignment: chatItemView.isRecipient
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          if (chatItemView.showDateHeading)
            ChatItemDateHeading(
              createdAt: chatItemView.createdAt,
            ),
          if (chatItemView.showName) //may show name of sender.
            Container(
              margin: EdgeInsets.only(bottom: 3),
              child: Text(
                chatItemView.isRecipient
                    ? chatProvider.recipientName
                    : chatProvider.myName,
                style: TextStyles.textStyle2,
              ),
            ),
          _buildChatItemWidget(),
        ],
      ),
    );
  }
}
