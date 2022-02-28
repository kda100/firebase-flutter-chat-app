import 'package:firebase_chat_app/constants/strings.dart';
import 'package:firebase_chat_app/widgets/fixed_profile_pic_widget.dart';
import 'package:firebase_chat_app/providers/chat_provider.dart';
import 'package:firebase_chat_app/widgets/send_message_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chat_stream.dart';

///main screen where all messages will be displayed and user will be able to send different
///types of messages.

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  Future<void>? setUpChatData;

  @override
  void initState() {
    setUpChatData =
        Provider.of<ChatProvider>(context, listen: false).setUpChatData();
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    Provider.of<ChatProvider>(context, listen: false)
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
                    Expanded(child: ChatStream()),
                    SendMessageWidget(),
                  ],
                );
              }
            }
          }),
    );
  }
}
