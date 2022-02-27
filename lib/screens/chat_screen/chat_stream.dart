import 'package:firebase_chat_app/helpers/datetime_helper.dart';
import 'package:firebase_chat_app/models/chat_content_item_models/chat_content_item.dart';
import 'package:firebase_chat_app/widgets/chat_content_item/chat_content_item_date_heading.dart';
import 'package:firebase_chat_app/widgets/chat_content_item/chat_content_item_holder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../chat_provider.dart';

///stream where messages will be constantly updated when messages are sent and received.
class ChatStream extends StatelessWidget {
  ///determines whether to display a date heading above a group of chat content items,
  ///if series of chat content items were sent on the same day then date will only be shown for
  ///the first chat content item.
  bool _showChatContentItemDate({
    required DateTime currCreatedAtDDMMYY,
    required DateTime prevCreatedAtDDMMYY,
  }) {
    if (currCreatedAtDDMMYY != prevCreatedAtDDMMYY) {
      return true;
    }
    return false;
  }

  ///determines whether to display a name heading above a group of chat content items,
  ///if series of chat content items were sent by the same user then name will only be shown for
  ///the first chat content item.
  bool _showChatContentItemName({
    required bool currIsRecipient,
    required bool prevIsRecipient,
    required DateTime currCreatedAtDDMMYY,
    required DateTime prevCreatedAtDDMMYY,
  }) {
    if (currIsRecipient != prevIsRecipient ||
        currCreatedAtDDMMYY != prevCreatedAtDDMMYY) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, ChatContentItem>?
        chatContentItemMap; //reference to chat content item map (messages)
    Iterable<String>? chatContentItemMapKeys;
    int itemCount = 0; // number of chat content items

    return StreamBuilder<Map<String, ChatContentItem>>(
      //updates (rebuilds) a message has been sent, received or deleted.
      stream: Provider.of<ChatProvider>(context, listen: false)
          .getChatContentItemMapStream,
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
          chatContentItemMap = chatContentItemMapSnapshot
              .data; //new reference to chat content items
          chatContentItemMapKeys = chatContentItemMap?.keys;
          itemCount = chatContentItemMap?.length ?? 0;
          return ListView.builder(
            //produces list of chat content items with the most recent messages at the bottom of list.
            reverse: true,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (chatContentItemMap != null &&
                  chatContentItemMapKeys != null) {
                index = itemCount - index - 1;
                final String currentId =
                    (chatContentItemMapKeys?.elementAt(index) ?? "");
                ChatContentItem currChatContentItem =
                    chatContentItemMap![currentId]!;
                bool showChatContentItemDate;
                bool showChatContentItemName;
                if (index == 0) {
                  showChatContentItemDate = true;
                  showChatContentItemName = true;
                } else {
                  ChatContentItem prevChatContentItem = chatContentItemMap![
                      chatContentItemMapKeys!.elementAt(index - 1)]!;
                  final DateTime currCreatedAtDDMMYY =
                      DateTimeHelper.formatDateTimeToYearMonthDay(
                          currChatContentItem.createdAt);
                  final DateTime prevCreatedAtDDMMYY =
                      DateTimeHelper.formatDateTimeToYearMonthDay(
                          prevChatContentItem.createdAt);
                  showChatContentItemDate = _showChatContentItemDate(
                    currCreatedAtDDMMYY: currCreatedAtDDMMYY,
                    prevCreatedAtDDMMYY: prevCreatedAtDDMMYY,
                  );
                  showChatContentItemName = _showChatContentItemName(
                    currIsRecipient: currChatContentItem.isRecipient,
                    prevIsRecipient: prevChatContentItem.isRecipient,
                    currCreatedAtDDMMYY: currCreatedAtDDMMYY,
                    prevCreatedAtDDMMYY: prevCreatedAtDDMMYY,
                  );
                }
                final ChatContentItemHolder chatContentItemHolder =
                    ChatContentItemHolder(
                  id: currentId,
                  chatContentItem: currChatContentItem,
                  showName: showChatContentItemName,
                );
                if (showChatContentItemDate)
                  return Column(
                    children: [
                      ChatContentItemDateHeading(
                        createdAt: currChatContentItem.createdAt,
                      ),
                      chatContentItemHolder,
                    ],
                  );
                else
                  return chatContentItemHolder;
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
