import 'package:firebase_chat_app/helpers/datetime_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utilities/text_styles.dart';

///widget to display date of a single chat content item (message) or a group.

class ChatItemDateHeading extends StatelessWidget {
  final DateTime createdAt;

  ChatItemDateHeading({required this.createdAt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16.0,
        left: 8.0,
        right: 8.0,
        bottom: 8.0,
      ),
      alignment: Alignment.center,
      child: Text(
        DateTimeHelper.formatDateTimeToDayMonthYearString(createdAt),
        style: TextStyles.textStyle2,
      ),
    );
  }
}
