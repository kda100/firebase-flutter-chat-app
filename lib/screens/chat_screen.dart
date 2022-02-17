import 'package:firebase_chat_app/models/chat_content_item.dart';
import 'package:firebase_chat_app/widgets/chat_content_item_date_heading.dart';
import 'package:firebase_chat_app/constants/strings.dart';
import 'package:firebase_chat_app/helpers/datetime_helper.dart';
import 'package:firebase_chat_app/widgets/fixed_profile_pic_widget.dart';
import 'package:firebase_chat_app/chat_provider.dart';
import 'package:firebase_chat_app/widgets/chat_content_item_holder.dart';
import 'package:firebase_chat_app/widgets/send_message_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///main screen where all messages will be displayed and user will be able to send different
///types of messages.

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  Map<String, dynamic>?
      coachChatContentItemMap; //reference to chat content item map
  Iterable<String>? coachChatContentItemMapKeys;
  int itemCount = 0; // number of chat content items
  ChatProvider? chatProvider;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider?.listenToCoachChatCloudFirebaseData();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    Provider.of<ChatProvider>(context, listen: false)
        .updateReadReceipts(); //updates read receipts when app changes state.
  }

  ///determines whether to display a date heading above a series of chat content item widgets,
  ///if series of chat content item widgets were sent on the same day then date will only be shown for
  ///the first chat content item widget.
  bool _showChatContentItemDate({
    required DateTime currCreatedAtDDMMYY,
    required DateTime prevCreatedAtDDMMYY,
  }) {
    if (currCreatedAtDDMMYY != prevCreatedAtDDMMYY) {
      return true;
    }
    return false;
  }

  ///determines whether to display a date heading above a group of chat content item widgets,
  ///if series of chat content item widgets were sent by the same user then name will only be shown for
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
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
            bottom: 8.0,
            left: 8.0,
          ),
          child: FixedProfilePicWidget(),
        ),
        title: Text(Strings.appName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<Map<String, dynamic>>(
              //waits for chat content item map to change.
              stream: chatProvider?.getCoachChatContentItemMapStream,
              builder: (context, coachChatContentItemMapSnapshot) {
                if (coachChatContentItemMapSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (coachChatContentItemMapSnapshot.hasError) {
                    return Center(
                      child: Text('An error has occurred'),
                    );
                  }
                  coachChatContentItemMap = coachChatContentItemMapSnapshot
                      .data; //replaces references to chat content items
                  coachChatContentItemMapKeys = coachChatContentItemMap?.keys;
                  itemCount = coachChatContentItemMap?.length ?? 0;
                  //produces list of chat content items with the most recent messages at the bottom of list.
                  return ListView.builder(
                    reverse: true,
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      index = itemCount - index - 1;
                      final String currentId =
                          (coachChatContentItemMapKeys?.elementAt(index) ?? "");
                      ChatContentItem currChatContentItem =
                          coachChatContentItemMap?[currentId];
                      bool showChatContentItemDate;
                      bool showChatContentItemName;
                      if (index == 0) {
                        showChatContentItemDate = true;
                        showChatContentItemName = true;
                      } else {
                        ChatContentItem prevChatContentItem =
                            coachChatContentItemMap?[coachChatContentItemMapKeys
                                ?.elementAt(index - 1)];
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
                    },
                  );
                }
              },
            ),
          ),
          SendMessageWidget(),
        ],
      ),
    );
  }
}
