import 'package:firebase_chat_app/models/chat_content_item_models/chat_content_item.dart';
import 'package:firebase_chat_app/models/chat_content_item_view_models/chat_content_item_view.dart';
import 'package:firebase_chat_app/widgets/chat_content_item_widgets/chat_content_item_holder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';

///stream where messages will be constantly updated when messages are sent and received.
class ChatStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);
    return StreamBuilder<Map<String, ChatContentItem>>(
      //updates (rebuilds) a message has been sent, received or deleted.
      stream: chatProvider.chatContentItemsMapStream,
      builder: (context, chatContentItemMapSnapshot) {
        if (chatContentItemMapSnapshot.connectionState ==
            ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (chatContentItemMapSnapshot.hasError) {
            return Center(
              child: Text(
                'An error has occurred',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            );
          }
          final Map<String, ChatContentItem>? chatContentItemsMap =
              chatContentItemMapSnapshot
                  .data; //new reference to chat content items
          final Iterable<String>? chatContentItemsMapKeys =
              chatContentItemsMap?.keys;
          final int itemCount = chatContentItemsMap?.length ?? 0;
          return ListView.builder(
            //produces list of chat content items with the most recent messages at the bottom of list.
            reverse: true,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (chatContentItemsMap != null &&
                  chatContentItemsMapKeys != null) {
                final ChatContentItemView chatContentItemView =
                    chatProvider.getChatContentItemView(
                        index: index,
                        chatContentItemsMap: chatContentItemsMap,
                        chatContentItemsMapKeys: chatContentItemsMapKeys,
                        itemCount: itemCount);

                return ChatContentItemHolder(
                  chatContentItemView: chatContentItemView,
                );
              }
              return Center(
                child: Text('An error has occurred'),
              );
            },
          );
        }
      },
    );
  }
}
