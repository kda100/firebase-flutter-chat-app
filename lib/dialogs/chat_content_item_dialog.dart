import 'package:firebase_chat_app/models/chat_item_view_models/cloud_chat_item_view.dart';
import 'package:firebase_chat_app/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'actionable_alert_dialog.dart';

/// Dialog used when long-pressing chat content item to allow user to unsend messages they send.

class ChatItemDialog extends StatelessWidget {
  final CloudChatItemView cloudChatItemView;

  ChatItemDialog({
    required this.cloudChatItemView,
  });

  @override
  Widget build(BuildContext context) {
    final ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);
    return Dialog(
      child: ListTile(
        onTap: () async {
          Navigator.of(context).pop();
          final bool? result = await showDialog(
            context: context,
            builder: (context) {
              return ActionableAlertDialog(
                title: "Are you sure you want to unsend?",
              );
            },
          );
          if (result != null && result) {
            chatProvider.unSendChatItem(id: cloudChatItemView.id);
          }
        },
        title: Text("Unsend?"),
      ),
    );
  }
}
