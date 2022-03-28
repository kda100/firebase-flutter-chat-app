import 'dart:io';

import 'package:firebase_chat_app/constants/text_styles.dart';
import 'package:firebase_chat_app/helpers/datetime_helper.dart';
import 'package:firebase_chat_app/models/chat_item_type.dart';
import 'package:firebase_chat_app/models/chat_item_view_models/cloud_chat_item_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'cloud_chat_image_and_video_widget.dart';
import 'cloud_chat_text_widget.dart';

/// Widget used to display ChatContentItems that have been uploaded to Firestore.
/// Widget can be displayed with a timestamp
/// and a check mark so user is aware of instance of upload and read receipts of their messages.
class CloudChatItemWidget extends StatelessWidget {
  final CloudChatItemView cloudChatItemView;

  CloudChatItemWidget({required this.cloudChatItemView});

  ///returns Media widgets and text widgets dependent on ChatContentItemType.
  Widget _buildCloudChatContentWidget() {
    if (cloudChatItemView.chatItemType == ChatItemType.TEXT) {
      return CloudChatTextWidget(
        cloudChatItemView: cloudChatItemView,
      );
    } else {
      return CloudChatImageAndVideoWidget(cloudChatItemView: cloudChatItemView);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: cloudChatItemView.isRecipient
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        _buildCloudChatContentWidget(),
        SizedBox(
          height: 2,
        ),
        Row(
          mainAxisAlignment: cloudChatItemView.isRecipient
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: [
            if (cloudChatItemView
                .onCloud) // time only displayed when message has reached the Firebase Firestore.
              Text(
                DateTimeHelper.formatDateTimeToTimeString(
                    cloudChatItemView.createdAt),
                style: TextStyles.primaryTextStyle,
              ),
            SizedBox(
              width: 2,
            ),
            if (!cloudChatItemView
                .isRecipient) //read receipts and instance of upload checks are only displayed if messages sent by user.
              Icon(
                cloudChatItemView.onCloud //instance of upload
                    ? FontAwesomeIcons.checkDouble
                    : FontAwesomeIcons.check,
                color: cloudChatItemView.read && // read receipts
                        cloudChatItemView.onCloud
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
