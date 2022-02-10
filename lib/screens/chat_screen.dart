import 'package:firebase_chat_app/widgets/error_message.dart';
import 'package:firebase_chat_app/widgets/loading_widget.dart';
import 'package:firebase_chat_app/constants/strings.dart';
import 'package:firebase_chat_app/helpers/datetime_helper.dart';
import 'package:firebase_chat_app/widgets/fixed_profile_pic_widget.dart';
import 'package:firebase_chat_app/providers/chat_provider.dart';
import 'package:firebase_chat_app/widgets/chat_content_item_date_heading.dart';
import 'package:firebase_chat_app/widgets/chat_content_item_holder.dart';
import 'package:firebase_chat_app/widgets/send_message_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    Provider.of<ChatProvider>(context, listen: false)
        .listenToCoachChatCloudFirebaseData();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    Provider.of<ChatProvider>(context, listen: false).updateReadReceipts();
  }

  bool _showChatContentItemDate({
    required DateTime currCreatedAtDDMMYY,
    required DateTime prevCreatedAtDDMMYY,
  }) {
    if (currCreatedAtDDMMYY != prevCreatedAtDDMMYY) {
      return true;
    }
    return false;
  }

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
    Map<String, dynamic>? coachChatContentItemMap;
    Iterable<String>? coachChatContentItemMapKeys;
    int itemCount = 0;
    final ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);

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
              stream: chatProvider.getCoachChatContentItemMapStream,
              builder: (context, coachChatContentItemMapData) {
                if (coachChatContentItemMapData.connectionState ==
                    ConnectionState.waiting) {
                  return LoadingWidget();
                } else {
                  if (coachChatContentItemMapData.hasError) {
                    return ErrorMessage();
                  }
                  coachChatContentItemMap = coachChatContentItemMapData.data;
                  coachChatContentItemMapKeys = coachChatContentItemMap?.keys;
                  itemCount = coachChatContentItemMap?.length ?? 0;
                  return ListView.builder(
                    reverse: true,
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      index = itemCount - index - 1;
                      final String currentId =
                          (coachChatContentItemMapKeys?.elementAt(index) ?? "");
                      var currChatContentItem =
                          coachChatContentItemMap?[currentId];
                      bool showChatContentItemDate;
                      bool showChatContentItemName;
                      if (index == 0) {
                        showChatContentItemDate = true;
                        showChatContentItemName = true;
                      } else {
                        var prevChatContentItem = coachChatContentItemMap?[
                            coachChatContentItemMapKeys?.elementAt(index - 1)];
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
