import 'package:firebase_chat_app/constants/strings.dart';
import 'package:firebase_chat_app/models/responses/chat_response.dart';
import 'package:firebase_chat_app/widgets/chat_item_widgets/chat_item_holder.dart';
import 'package:firebase_chat_app/widgets/fixed_profile_pic_widget.dart';
import 'package:firebase_chat_app/providers/chat_provider.dart';
import 'package:firebase_chat_app/widgets/send_message_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///main screen where all messages will be displayed and where user will be able to send different
///types of messages.

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  late ChatProvider chatProvider;
  late Future<void> setUpChatData;

  @override
  void initState() {
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    setUpChatData = chatProvider.setUpChatData();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    chatProvider
        .updateReadReceipts(); //updates read receipts when app changes state.
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
      body: FutureBuilder(
          future: setUpChatData,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (snap.hasError) {
                print(snap.error);
                return Center(
                  child: Text(
                    'An error has occurred',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                );
              } else {
                return Column(
                  children: [
                    Expanded(
                      child: Selector<ChatProvider, ChatResponse>(
                        //updates (rebuilds) a message has been sent, received or deleted.
                        selector: (context, chatProvider) =>
                            chatProvider.chatResponse,
                        builder: (context, chatResponse, _) {
                          if (chatResponse.chatResponseStatus ==
                              ChatResponseStatus.LOADING) {
                            //chat messages are loading.
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (chatResponse.chatResponseStatus ==
                              ChatResponseStatus.ERROR) {
                            //error in getting chat messages.
                            return Center(
                              child: Text(
                                chatResponse.message,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            //produces list of chat content item views with the most recent messages at the bottom of list.
                            shrinkWrap: true,
                            reverse: true,
                            itemCount: chatProvider.chatItemsCount,
                            itemBuilder: (context, index) {
                              return ChatItemHolder(
                                chatItemView:
                                    chatProvider.getChatItemView(index: index),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SendMessageWidget()
                  ],
                );
              }
            }
          }),
    );
  }
}
