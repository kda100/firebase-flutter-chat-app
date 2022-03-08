import 'package:firebase_chat_app/helpers/datetime_helper.dart';
import 'package:firebase_chat_app/models/chat_content_item_type.dart';
import 'package:firebase_chat_app/models/chat_content_item_view_models/cloud_chat_content_item_view.dart';
import 'package:firebase_chat_app/widgets/chat_content_item_widgets/cloud_chat_content_item_widgets/chat_text_item_widget.dart';
import 'package:firebase_chat_app/widgets/chat_content_item_widgets/cloud_chat_content_item_widgets/cloud_chat_media_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Widget used to display ChatContentItems that have been uploaded to Firestore.
/// Widget can be displayed with a timestamp
/// and a check mark so user is aware of instance of upload and read receipts of their messages.
class CloudChatContentItemWidget extends StatelessWidget {
  final CloudChatContentItemView cloudChatContentItemView;

  CloudChatContentItemWidget({required this.cloudChatContentItemView});

  ///returns Media widgets and text widgets dependent on ChatContentItemType.
  Widget _buildCloudChatContentItemWidget() {
    if (cloudChatContentItemView.chatContentItemType ==
        ChatContentItemType.TEXT) {
      return ChatTextItemWidget(
        cloudChatContentItemView: cloudChatContentItemView,
      );
    } else {
      return CloudChatMediaItemWidget(
          cloudChatContentItemView: cloudChatContentItemView);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: cloudChatContentItemView.isRecipient
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        _buildCloudChatContentItemWidget(),
        Row(
          mainAxisAlignment: cloudChatContentItemView.isRecipient
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: [
            if (cloudChatContentItemView
                .onCloud) // time only displayed when message has reached the Firebase Firestore.
              Container(
                margin: EdgeInsets.only(top: 3),
                child: Text(
                  DateTimeHelper.formatDateTimeToTimeString(
                      cloudChatContentItemView.createdAt),
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                        fontSize: 11,
                      ),
                ),
              ),
            SizedBox(
              width: 2,
            ),
            if (!cloudChatContentItemView
                .isRecipient) //read receipts and instance of upload checks are only displayed if messages sent by user.
              Icon(
                cloudChatContentItemView.onCloud //instance of upload
                    ? FontAwesomeIcons.checkDouble
                    : FontAwesomeIcons.check,
                color: cloudChatContentItemView.read && // read receipts
                        cloudChatContentItemView.onCloud
                    ? Colors.blue
                    : Colors.black,
                size: 10,
              ),
          ],
        ),
      ],
    );
  }
}
