import 'package:firebase_chat_app/helpers/datetime_helper.dart';
import 'package:flutter/material.dart';

///widget to display day of chat content items in a series of chat content items.

class ChatContentItemDateHeading extends StatelessWidget {
  final DateTime createdAt;

  ChatContentItemDateHeading({required this.createdAt});

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
        style: Theme.of(context).textTheme.bodyText1?.copyWith(
              fontSize: 11,
            ),
      ),
    );
  }
}
