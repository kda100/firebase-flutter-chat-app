import 'package:firebase_chat_app/constants/text_styles.dart';
import 'package:flutter/material.dart';

/// Dialog used when long-pressing chat content item to allow user to unsend messages they send.

class ChatItemDialog extends StatelessWidget {
  final void Function() onUnsend;

  ChatItemDialog({
    required this.onUnsend,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ListTile(
        onTap: () async {
          Navigator.of(context).pop();
          onUnsend();
        },
        title: Text(
          "Unsend?",
          style: TextStyles.primaryTextStyle,
        ),
      ),
    );
  }
}
